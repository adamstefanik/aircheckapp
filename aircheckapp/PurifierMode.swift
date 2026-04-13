import Foundation

enum PurifierMode: String, CaseIterable, Codable {
    case auto = "auto"
    case silent = "silent"
    case favorite = "favorite"
    case idle = "idle"

    var displayName: String {
        switch self {
        case .auto:     return "Auto"
        case .silent:   return "Silent"
        case .favorite: return "Fav"
        case .idle:     return "Idle"
        }
    }
}
