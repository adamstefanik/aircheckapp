import SwiftUI
import WidgetKit

struct WidgetSmallView: View {
    let entry: PurifierEntry

    var body: some View {
        if let status = entry.status {
            let level = status.airQualityLevel
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(level.color.opacity(0.2))
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: min(Double(status.pm25) / 150.0, 1.0))
                        .stroke(level.color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(status.pm25)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(level.color)
                        Text("PM2.5")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(entry.config?.name ?? "")
                    .font(.caption2)
                    .lineLimit(1)
                Text(status.isOn ? "Zapnuté" : "Vypnuté")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(spacing: 6) {
                Image(systemName: "wifi.slash")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text(entry.error ?? "Offline")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
