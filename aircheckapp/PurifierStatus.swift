import Foundation

struct PurifierStatus: Codable {
    let isOn: Bool
    let pm25: Int
    let temperature: Double
    let humidity: Int
    let mode: PurifierMode
    let favoriteLevel: Int
    let filterLifeRemaining: Int
    let motorSpeed: Int
    let fetchedAt: Date

    var airQualityLevel: AirQualityLevel { AirQualityLevel(pm25: pm25) }
}
