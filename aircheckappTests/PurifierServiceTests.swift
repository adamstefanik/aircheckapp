import XCTest
@testable import aircheckapp

final class MockMiIOConnection: MiIOConnecting {
    var deviceId: UInt32 = 0
    var timestamp: UInt32 = 0
    var connectCalled = false
    var sentCommands: [(String, [Any])] = []
    var responseToReturn: [String: Any] = [:]

    func connect() async throws { connectCalled = true }
    func disconnect() {}
    func send(method: String, params: [Any]) async throws -> [String: Any] {
        sentCommands.append((method, params))
        return responseToReturn
    }
}

final class PurifierServiceTests: XCTestCase {
    func test_miIO_getStatus_sendsGetProp() async throws {
        let mock = MockMiIOConnection()
        mock.responseToReturn = ["result": ["on", 25, 55, 235, "auto", 10, 80, 1200]]
        let service = PurifierService(connection: mock, protocolVersion: .miIO)
        let status = try await service.getStatus()
        XCTAssertEqual(mock.sentCommands.first?.0, "get_prop")
        XCTAssertTrue(status.isOn)
        XCTAssertEqual(status.pm25, 25)
        XCTAssertEqual(status.filterLifeRemaining, 80)
        XCTAssertEqual(status.mode, .auto)
    }

    func test_miOT_getStatus_sendsGetProperties() async throws {
        let mock = MockMiIOConnection()
        mock.responseToReturn = ["result": [
            ["did": "power",        "value": true],
            ["did": "mode",         "value": 0],
            ["did": "aqi",          "value": 30],
            ["did": "humidity",     "value": 50],
            ["did": "temp",         "value": 22.5],
            ["did": "filter_life",  "value": 75],
            ["did": "motor_speed",  "value": 1200],
            ["did": "fav_level",    "value": 8]
        ]]
        let service = PurifierService(connection: mock, protocolVersion: .miOT)
        let status = try await service.getStatus()
        XCTAssertEqual(mock.sentCommands.first?.0, "get_properties")
        XCTAssertTrue(status.isOn)
        XCTAssertEqual(status.pm25, 30)
        XCTAssertEqual(status.filterLifeRemaining, 75)
        XCTAssertEqual(status.mode, .auto)
    }

    func test_connect_callsConnectionConnect() async throws {
        let mock = MockMiIOConnection()
        let service = PurifierService(connection: mock, protocolVersion: .miIO)
        try await service.connect()
        XCTAssertTrue(mock.connectCalled)
    }
}
