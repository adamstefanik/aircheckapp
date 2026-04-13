// aircheckappTests/MiIOPacketTests.swift
import XCTest
@testable import aircheckapp

final class MiIOPacketTests: XCTestCase {
    let token = Data([0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,
                      0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff])

    func test_helloPacket_is32Bytes() {
        XCTAssertEqual(MiIOPacket.helloPacket().count, 32)
    }

    func test_helloPacket_startsWithMagic() {
        let h = MiIOPacket.helloPacket()
        XCTAssertEqual(h[0], 0x21)
        XCTAssertEqual(h[1], 0x31)
    }

    func test_helloPacket_lengthFieldIs32() {
        let h = MiIOPacket.helloPacket()
        let length = UInt16(h[2]) << 8 | UInt16(h[3])
        XCTAssertEqual(length, 32)
    }

    func test_helloPacket_payloadBytesAreFF() {
        let h = MiIOPacket.helloPacket()
        for i in 4..<32 { XCTAssertEqual(h[i], 0xFF, "byte \(i) should be 0xFF") }
    }

    func test_buildAndParse_roundtrip() throws {
        let json = #"{"id":1,"method":"get_prop","params":["power"]}"#
        let packet = try MiIOPacket.buildPacket(
            deviceId: 0x12345678, timestamp: 1000,
            token: token, payload: json.data(using: .utf8)!)
        XCTAssertEqual(packet[0], 0x21)
        XCTAssertEqual(packet[1], 0x31)
        XCTAssertGreaterThan(packet.count, 32)
        let parsed = try MiIOPacket.parse(packet, token: token)
        XCTAssertEqual(parsed.deviceId, 0x12345678)
        XCTAssertEqual(parsed.json?["method"] as? String, "get_prop")
    }

    func test_parseHelloResponse_noPayload() throws {
        var d = Data(count: 32)
        d[0]=0x21; d[1]=0x31; d[2]=0x00; d[3]=0x20
        d[8]=0xAA; d[9]=0xBB; d[10]=0xCC; d[11]=0xDD
        let p = try MiIOPacket.parse(d, token: Data(count: 16))
        XCTAssertEqual(p.deviceId, 0xAABBCCDD)
        XCTAssertNil(p.json)
    }
}
