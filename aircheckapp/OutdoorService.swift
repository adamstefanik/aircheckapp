import Foundation

struct OutdoorData: Codable {
    let aqi: Int?
    let temperature: Double?
}

final class OutdoorService {
    private let city: String
    private let aqicnToken: String

    private static let coords: [String: (lat: Double, lon: Double)] = [
        "zlin":      (49.2264, 17.6712),
        "zlín":      (49.2264, 17.6712),
        "handlova":  (48.7275, 18.7589),
        "handlová":  (48.7275, 18.7589),
        "bratislava":(48.1486, 17.1077),
        "praha":     (50.0755, 14.4378),
        "prague":    (50.0755, 14.4378)
    ]

    init(city: String, aqicnToken: String) {
        self.city = city
        self.aqicnToken = aqicnToken
    }

    func fetch() async -> OutdoorData {
        async let aqi = fetchAQI()
        async let temp = fetchTemperature()
        return OutdoorData(aqi: await aqi, temperature: await temp)
    }

    private func fetchAQI() async -> Int? {
        guard !aqicnToken.isEmpty, !city.isEmpty,
              let url = URL(string: "https://api.waqi.info/feed/\(city)/?token=\(aqicnToken)") else {
            return nil
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any] else {
            return nil
        }
        return dataObj["aqi"] as? Int
    }

    private func fetchTemperature() async -> Double? {
        let key = city.lowercased().trimmingCharacters(in: .whitespaces)
        guard let c = Self.coords[key],
              let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(c.lat)&longitude=\(c.lon)&current=temperature_2m") else {
            return nil
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let current = json["current"] as? [String: Any] else {
            return nil
        }
        return (current["temperature_2m"] as? Double) ?? (current["temperature_2m"] as? NSNumber).map { Double(truncating: $0) }
    }
}
