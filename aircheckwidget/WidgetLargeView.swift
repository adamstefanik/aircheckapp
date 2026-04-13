import SwiftUI

struct WidgetLargeView: View {
    let entry: PurifierEntry

    var body: some View {
        if let status = entry.status {
            let level = status.airQualityLevel
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(entry.config?.name ?? "")
                        .font(.title2.bold())
                    Spacer()
                    Text(status.isOn ? "ON" : "OFF")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(status.isOn ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundStyle(status.isOn ? .green : .red)
                        .clipShape(Capsule())
                }

                // PM2.5 + sensors
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(level.color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0, to: min(Double(status.pm25) / 150.0, 1.0))
                            .stroke(level.color, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 1) {
                            Text("\(status.pm25)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(level.color)
                            Text("PM2.5")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                            Text(level.label)
                                .font(.system(size: 8))
                                .foregroundStyle(level.color)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Mód: \(status.mode.displayName)", systemImage: "wind")
                        Label("Motor: \(status.motorSpeed) RPM", systemImage: "fan")
                        Label(status.isOn ? "Zapnuté" : "Vypnuté", systemImage: "power")
                    }
                    .font(.subheadline)
                    Spacer(minLength: 0)
                }

                Divider()

                // Filter
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Filter").font(.subheadline.bold())
                        Spacer()
                        Text("\(status.filterLifeRemaining)%")
                            .foregroundStyle(status.filterLifeRemaining < 20 ? .red : .primary)
                            .font(.subheadline)
                    }
                    ProgressView(value: Double(status.filterLifeRemaining) / 100.0)
                        .tint(status.filterLifeRemaining < 20 ? .red : level.color)
                }

                Spacer(minLength: 0)

                // Footer
                Text("Aktualizovan\u{00E9} \(status.fetchedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(4)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(entry.error ?? "Offline")
                    .foregroundStyle(.secondary)
                if entry.config == nil {
                    Text("Otvor appku a nastav zariadenie")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
