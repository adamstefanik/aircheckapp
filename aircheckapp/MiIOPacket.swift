import Foundation

struct MiIOPacket {
    static func helloPacket() -> Data {
        var d = Data(count: 32)
        d[0]=0x21; d[1]=0x31; d[2]=0x00; d[3]=0x20
        for i in 4..<32 { d[i] = 0xFF }
        return d
    }

    static func buildPacket(deviceId: UInt32, timestamp: UInt32,
                             token: Data, payload: Data) throws -> Data {
        let crypto = MiIOCrypto(token: token)
        let enc = try crypto.encrypt(payload)
        let totalLen = UInt16(32 + enc.count)

        var h = Data(count: 32)
        h[0]=0x21; h[1]=0x31
        h[2]=UInt8(totalLen >> 8); h[3]=UInt8(totalLen & 0xFF)
        // deviceId big-endian bytes 8-11
        h[8]=UInt8((deviceId>>24)&0xFF); h[9]=UInt8((deviceId>>16)&0xFF)
        h[10]=UInt8((deviceId>>8)&0xFF); h[11]=UInt8(deviceId&0xFF)
        // timestamp big-endian bytes 12-15
        h[12]=UInt8((timestamp>>24)&0xFF); h[13]=UInt8((timestamp>>16)&0xFF)
        h[14]=UInt8((timestamp>>8)&0xFF);  h[15]=UInt8(timestamp&0xFF)
        // put token in checksum slot, then compute checksum
        h.replaceSubrange(16..<32, with: token)
        h.replaceSubrange(16..<32, with: crypto.buildChecksum(header: h, payload: enc))
        return h + enc
    }

    static func parse(_ data: Data, token: Data) throws
        -> (deviceId: UInt32, timestamp: UInt32, json: [String: Any]?) {
        guard data.count >= 32, data[0]==0x21, data[1]==0x31 else { throw MiIOError.invalidPacket }
        let length = UInt16(data[2])<<8 | UInt16(data[3])
        let deviceId  = UInt32(data[8])<<24|UInt32(data[9])<<16|UInt32(data[10])<<8|UInt32(data[11])
        let timestamp = UInt32(data[12])<<24|UInt32(data[13])<<16|UInt32(data[14])<<8|UInt32(data[15])
        // Hello response: length == 32, no payload
        guard length > 32, data.count > 32 else { return (deviceId, timestamp, nil) }
        let decrypted = try MiIOCrypto(token: token).decrypt(data.subdata(in: 32..<data.count))
        let json = try JSONSerialization.jsonObject(with: decrypted) as? [String: Any]
        return (deviceId, timestamp, json)
    }
}
