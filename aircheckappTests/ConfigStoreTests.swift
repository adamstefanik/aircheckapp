import XCTest
@testable import aircheckapp

final class ConfigStoreTests: XCTestCase {
    var store: ConfigStore!

    override func setUp() {
        store = ConfigStore(suiteName: nil) // standard UserDefaults for tests
        store.clear()
    }

    func test_saveAndLoad() {
        let config = DeviceConfig(name: "Obývačka", ipAddress: "192.168.1.42",
                                   protocolVersion: .miOT)
        store.save(config)
        let loaded = store.load()
        XCTAssertEqual(loaded?.name, "Obývačka")
        XCTAssertEqual(loaded?.ipAddress, "192.168.1.42")
        XCTAssertEqual(loaded?.protocolVersion, .miOT)
    }

    func test_load_returnsNil_whenEmpty() {
        XCTAssertNil(store.load())
    }

    func test_overwrite() {
        store.save(DeviceConfig(name: "A", ipAddress: "1.1.1.1", protocolVersion: .miIO))
        store.save(DeviceConfig(name: "B", ipAddress: "2.2.2.2", protocolVersion: .miOT))
        XCTAssertEqual(store.load()?.name, "B")
    }
}
