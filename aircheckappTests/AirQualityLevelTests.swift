import XCTest
@testable import aircheckapp

final class AirQualityLevelTests: XCTestCase {
    func test_pm25Thresholds() {
        XCTAssertEqual(AirQualityLevel(pm25: 0),   .excellent)
        XCTAssertEqual(AirQualityLevel(pm25: 35),  .excellent)
        XCTAssertEqual(AirQualityLevel(pm25: 36),  .good)
        XCTAssertEqual(AirQualityLevel(pm25: 75),  .good)
        XCTAssertEqual(AirQualityLevel(pm25: 76),  .moderate)
        XCTAssertEqual(AirQualityLevel(pm25: 115), .moderate)
        XCTAssertEqual(AirQualityLevel(pm25: 116), .poor)
        XCTAssertEqual(AirQualityLevel(pm25: 150), .poor)
        XCTAssertEqual(AirQualityLevel(pm25: 151), .hazardous)
    }
}
