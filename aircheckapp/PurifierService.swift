import Foundation

final class PurifierService {
    private let connection: MiIOConnecting
    private let protocolVersion: DeviceConfig.ProtocolVersion

    init(connection: MiIOConnecting, protocolVersion: DeviceConfig.ProtocolVersion) {
        self.connection = connection
        self.protocolVersion = protocolVersion
    }

    func connect() async throws {
        try await connection.connect()
        if protocolVersion == .miOT {
            _ = try? await connection.send(method: "set_properties", params: [[
                "did": "aqi-updata-heartbeat", "siid": 13, "piid": 9, "value": 60
            ]])
        }
    }

    func getStatus() async throws -> PurifierStatus {
        switch protocolVersion {
        case .miIO: return try await getStatusMiIO()
        case .miOT: return try await getStatusMiOT()
        }
    }

    // MARK: - Private

    private func getStatusMiIO() async throws -> PurifierStatus {
        let r = try await connection.send(method: "get_prop",
            params: ["power", "aqi", "humidity", "temp_dec", "mode",
                     "favorite_level", "filter_life_remaining", "motor_speed"])
        guard let result = r["result"] as? [Any], result.count >= 8 else {
            throw MiIOError.invalidPacket
        }
        return PurifierStatus(
            isOn:                (result[0] as? String) == "on",
            pm25:                result[1] as? Int ?? 0,
            temperature:         Double(result[3] as? Int ?? 0) / 10.0,
            humidity:            result[2] as? Int ?? 0,
            mode:                PurifierMode(rawValue: result[4] as? String ?? "auto") ?? .auto,
            favoriteLevel:       result[5] as? Int ?? 0,
            filterLifeRemaining: result[6] as? Int ?? 0,
            motorSpeed:          result[7] as? Int ?? 0,
            fetchedAt:           Date()
        )
    }

    private func getStatusMiOT() async throws -> PurifierStatus {
        let r = try await connection.send(method: "get_properties", params: [
            ["did": "power",       "siid": 2,  "piid": 1],
            ["did": "mode",        "siid": 2,  "piid": 4],
            ["did": "aqi",         "siid": 3,  "piid": 4],
            ["did": "filter_life", "siid": 4,  "piid": 1],
            ["did": "motor_speed", "siid": 11, "piid": 4]
        ])
        guard let result = r["result"] as? [[String: Any]] else {
            throw MiIOError.invalidPacket
        }
        func val(_ did: String) -> Any? {
            result.first { $0["did"] as? String == did }?["value"]
        }
        let modeMap: [Int: PurifierMode] = [0: .auto, 1: .silent, 2: .favorite, 3: .idle]
        return PurifierStatus(
            isOn:                val("power") as? Bool ?? false,
            pm25:                val("aqi") as? Int ?? 0,
            temperature:         0,
            humidity:            0,
            mode:                modeMap[val("mode") as? Int ?? 0] ?? .auto,
            favoriteLevel:       0,
            filterLifeRemaining: val("filter_life") as? Int ?? 0,
            motorSpeed:          val("motor_speed") as? Int ?? 0,
            fetchedAt:           Date()
        )
    }
}
