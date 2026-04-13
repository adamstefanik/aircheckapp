import SwiftUI

enum AirQualityLevel: Equatable {
    case excellent, good, moderate, poor, hazardous

    init(pm25: Int) {
        switch pm25 {
        case ...35:     self = .excellent
        case 36...75:   self = .good
        case 76...115:  self = .moderate
        case 116...150: self = .poor
        default:        self = .hazardous
        }
    }

    var color: Color {
        switch self {
        case .excellent: return Color(hex: "#34C759")
        case .good:      return Color(hex: "#FFD60A")
        case .moderate:  return Color(hex: "#FF9500")
        case .poor:      return Color(hex: "#FF3B30")
        case .hazardous: return Color(hex: "#AF52DE")
        }
    }

    var label: String {
        switch self {
        case .excellent: return "Výborná"
        case .good:      return "Dobrá"
        case .moderate:  return "Mierna"
        case .poor:      return "Zlá"
        case .hazardous: return "Nebezpečná"
        }
    }
}
