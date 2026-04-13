// aircheckappTests/DataHexTests.swift
import XCTest
@testable import aircheckapp

final class DataHexTests: XCTestCase {
    func test_hexToData_validToken() {
        let data = Data(hexString: "00112233445566778899aabbccddeeff")
        XCTAssertEqual(data?.count, 16)
        XCTAssertEqual(data?[0], 0x00)
        XCTAssertEqual(data?[15], 0xFF)
    }

    func test_hexToData_uppercase() {
        let data = Data(hexString: "AABBCCDD")
        XCTAssertEqual(data?.count, 4)
        XCTAssertEqual(data?[0], 0xAA)
    }

    func test_hexToData_oddLength_returnsNil() {
        XCTAssertNil(Data(hexString: "abc"))
    }

    func test_hexToData_invalidChars_returnsNil() {
        XCTAssertNil(Data(hexString: "ZZZZ"))
    }

    func test_dataToHex() {
        XCTAssertEqual(Data([0xDE, 0xAD, 0xBE, 0xEF]).hexString, "deadbeef")
    }

    func test_hexToData_withSpaces_returnsNil() {
        XCTAssertNil(Data(hexString: "00 11 22 33"))
    }

    func test_hexToData_empty_returnsEmptyData() {
        XCTAssertEqual(Data(hexString: "")?.count, 0)
    }

    func test_roundtrip() {
        let original = Data([0x00, 0x11, 0xAA, 0xFF])
        XCTAssertEqual(Data(hexString: original.hexString), original)
    }
}
