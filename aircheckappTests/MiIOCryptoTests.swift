import XCTest
@testable import aircheckapp

final class MiIOCryptoTests: XCTestCase {
    let token = Data([0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,
                      0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff])

    func test_key_is16Bytes() {
        XCTAssertEqual(MiIOCrypto(token: token).key.count, 16)
    }

    func test_iv_is16Bytes_andDiffersFromKey() {
        let c = MiIOCrypto(token: token)
        XCTAssertEqual(c.iv.count, 16)
        XCTAssertNotEqual(c.iv, c.key)
    }

    func test_encryptDecrypt_roundtrip() throws {
        let crypto = MiIOCrypto(token: token)
        let plain = #"{"id":1,"method":"get_prop","params":["power"]}"#.data(using: .utf8)!
        let decrypted = try crypto.decrypt(try crypto.encrypt(plain))
        XCTAssertEqual(decrypted, plain)
    }

    func test_checksum_is16Bytes() {
        let c = MiIOCrypto(token: token)
        XCTAssertEqual(c.buildChecksum(header: Data(count: 32), payload: Data([1,2])).count, 16)
    }
}
