import Foundation

struct OutdoorData: Codable {
    let aqi: Int?
    let temperature: Double?
}

final class OutdoorService {
    private let city: String
    private let aqicnToken: String

    init(city: String, aqicnToken: String) {
        self.city = city
        self.aqicnToken = aqicnToken
    }

    func fetch() async -> OutdoorData {
        guard !aqicnToken.isEmpty, !city.isEmpty,
              let url = URL(string: "https://api.waqi.info/feed/\(city)/?token=\(aqicnToken)") else {
            return OutdoorData(aqi: nil, temperature: nil)
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any] else {
            return OutdoorData(aqi: nil, temperature: nil)
        }
        let aqi = dataObj["aqi"] as? Int
        let temp = (dataObj["iaqi"] as? [String: Any])?["t"] as? [String: Any]
        let temperature = (temp?["v"] as? Double) ?? (temp?["v"] as? NSNumber).map { Double(truncating: $0) }
        return OutdoorData(aqi: aqi, temperature: temperature)
    }
}
