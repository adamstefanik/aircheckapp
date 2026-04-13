import SwiftUI

struct WidgetMediumView: View {
    let entry: PurifierEntry

    var body: some View {
        if let status = entry.status {
            let level = status.airQualityLevel
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(level.color.opacity(0.15))
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: min(Double(status.pm25) / 150.0, 1.0))
                        .stroke(level.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Text("\(status.pm25)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(level.color)
                        Text("PM2.5")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.config?.name ?? "")
                        .font(.headline)
                        .lineLimit(1)
                    Label(status.mode.displayName, systemImage: "wind")
                        .font(.subheadline)
                    Label("Filter: \(status.filterLifeRemaining)%", systemImage: "air.purifier")
                        .font(.subheadline)
                    Text(status.isOn ? "Zapnuté" : "Vypnuté")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 4)
        } else {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text(entry.error ?? "Offline")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
