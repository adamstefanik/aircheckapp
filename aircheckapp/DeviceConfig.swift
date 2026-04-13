import Foundation

struct DeviceConfig: Codable {
    var name: String
    var ipAddress: String
    var protocolVersion: ProtocolVersion

    enum ProtocolVersion: String, Codable, CaseIterable {
        case miIO = "miIO"
        case miOT = "miOT"
    }
}
