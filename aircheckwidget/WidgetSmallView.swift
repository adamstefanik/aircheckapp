import SwiftUI
import WidgetKit

struct WidgetSmallView: View {
    let entry: PurifierEntry

    var body: some View {
        if let status = entry.status {
            let level = status.airQualityLevel
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        if let city = entry.config?.city, !city.isEmpty {
                            Text(city)
                                .font(.system(size: 18, weight: .semibold))
                                .lineLimit(1)
                        }
                        if let temp = entry.outdoor?.temperature {
                            Text(String(format: "%.0f°", temp))
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let aqi = entry.outdoor?.aqi {
                        HStack(spacing: 3) {
                            Image(systemName: "wind")
                                .frame(width: 14)
                            Text("AQI \(aqi)")
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "slider.horizontal.3")
                            .frame(width: 14)
                        Text(status.mode.displayName)
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    Text(status.isOn ? "ON" : "OFF")
                        .font(.caption.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(status.isOn ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundStyle(status.isOn ? .green : .red)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                ZStack {
                    Circle()
                        .fill(level.color.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: min(Double(status.pm25) / 150.0, 1.0))
                        .stroke(level.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(status.pm25)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(level.color)
                        Text("PM2.5")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .padding(0)
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
