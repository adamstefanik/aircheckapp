import Foundation
import CommonCrypto
import CryptoKit

struct MiIOCrypto {
    let token: Data

    var key: Data { Data(Insecure.MD5.hash(data: token)) }
    var iv: Data  { Data(Insecure.MD5.hash(data: key + token)) }

    func encrypt(_ plaintext: Data) throws -> Data {
        try aesCBC(CCOperation(kCCEncrypt), data: plaintext)
    }

    func decrypt(_ ciphertext: Data) throws -> Data {
        try aesCBC(CCOperation(kCCDecrypt), data: ciphertext)
    }

    func buildChecksum(header: Data, payload: Data) -> Data {
        let input = header.prefix(16) + token + payload
        return Data(Insecure.MD5.hash(data: input))
    }

    private func aesCBC(_ op: CCOperation, data: Data) throws -> Data {
        let keyB = [UInt8](key), ivB = [UInt8](iv), dataB = [UInt8](data)
        let bufSize = dataB.count + kCCBlockSizeAES128
        var out = [UInt8](repeating: 0, count: bufSize)
        var outLen = 0
        let status = CCCrypt(op, CCAlgorithm(kCCAlgorithmAES128),
                             CCOptions(kCCOptionPKCS7Padding),
                             keyB, kCCKeySizeAES128, ivB,
                             dataB, dataB.count, &out, bufSize, &outLen)
        guard status == kCCSuccess else { throw MiIOError.cryptoFailed(Int(status)) }
        return Data(out.prefix(outLen))
    }
}

enum MiIOError: Error {
    case cryptoFailed(Int)
    case invalidPacket
    case timeout
    case notConnected
}
