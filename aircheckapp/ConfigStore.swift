import Foundation

final class ConfigStore {
    private let defaults: UserDefaults
    private let configKey = "deviceConfig"

    init(suiteName: String?) {
        if let suiteName {
            defaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            defaults = .standard
        }
    }

    static let shared = ConfigStore(suiteName: "group.com.aircheckapp")

    func save(_ config: DeviceConfig) {
        if let data = try? JSONEncoder().encode(config) {
            defaults.set(data, forKey: configKey)
        }
    }

    func load() -> DeviceConfig? {
        guard let data = defaults.data(forKey: configKey) else { return nil }
        return try? JSONDecoder().decode(DeviceConfig.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: configKey)
    }
}
