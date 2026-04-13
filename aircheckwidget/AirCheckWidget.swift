import WidgetKit
import SwiftUI

// MARK: - Entry

struct PurifierEntry: TimelineEntry {
    let date: Date
    let config: DeviceConfig?
    let status: PurifierStatus?
    let error: String?
}

// MARK: - Timeline Provider

struct AirCheckTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PurifierEntry {
        PurifierEntry(
            date: Date(),
            config: DeviceConfig(name: "Obývačka", ipAddress: "", protocolVersion: .miOT),
            status: PurifierStatus(
                isOn: true, pm25: 23, temperature: 22.5, humidity: 48,
                mode: .auto, favoriteLevel: 8, filterLifeRemaining: 80,
                motorSpeed: 1200, fetchedAt: Date()
            ),
            error: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PurifierEntry) -> Void) {
        Task { completion(await fetchEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PurifierEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    private func fetchEntry() async -> PurifierEntry {
        guard let config = ConfigStore.shared.load() else {
            return PurifierEntry(date: Date(), config: nil, status: nil,
                                 error: "Nastav zariadenie v appke")
        }
        guard let token = try? TokenStorage.load() else {
            return PurifierEntry(date: Date(), config: config, status: nil,
                                 error: "Token nenájdený — otvor appku")
        }
        do {
            let conn = MiIOConnection(host: config.ipAddress, token: token)
            let service = PurifierService(connection: conn, protocolVersion: config.protocolVersion)
            try await service.connect()
            let status = try await service.getStatus()
            conn.disconnect()
            return PurifierEntry(date: Date(), config: config, status: status, error: nil)
        } catch {
            return PurifierEntry(date: Date(), config: config, status: nil, error: "Offline")
        }
    }
}

// MARK: - Widget

struct AirCheckWidget: Widget {
    let kind = "AirCheckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AirCheckTimelineProvider()) { entry in
            AirCheckWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Air Check")
        .description("PM2.5, teplota, vlhkosť a stav filtra.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Entry View (dispatcher)

struct AirCheckWidgetEntryView: View {
    let entry: PurifierEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  WidgetSmallView(entry: entry)
        case .systemMedium: WidgetMediumView(entry: entry)
        case .systemLarge:  WidgetLargeView(entry: entry)
        default:            WidgetSmallView(entry: entry)
        }
    }
}
