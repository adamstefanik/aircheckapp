import SwiftUI
import WidgetKit

struct SettingsView: View {
    @State private var ip         = Secrets.defaultIP
    @State private var token      = Secrets.defaultToken
    @State private var proto      = DeviceConfig.ProtocolVersion.miOT
    @State private var city       = ""
    @State private var aqicnToken = Secrets.defaultAQICNToken
    @State private var saved      = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Zariadenie") {
                    TextField("IP adresa (192.168.x.x)", text: $ip)
                        #if os(iOS)
                        .keyboardType(.numbersAndPunctuation)
                        #endif
                    TextField("32-znakový hex token", text: $token)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                Section("Vonkajšie podmienky (voliteľné)") {
                    TextField("Mesto (napr. Bratislava)", text: $city)
                        .autocorrectionDisabled()
                    TextField("AQICN token", text: $aqicnToken)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                Section("Protokol") {
                    Picker("Protokol", selection: $proto) {
                        Text("miIO (AP2, Pro)").tag(DeviceConfig.ProtocolVersion.miIO)
                        Text("MiOT (AP3H, AP4, AP4 Pro)").tag(DeviceConfig.ProtocolVersion.miOT)
                    }
                }
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                if saved {
                    Label("Uložené! Widget sa aktualizuje.", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                }
            }
            .navigationTitle("Air Check")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uložiť") { saveConfig() }
                        .disabled(ip.isEmpty || token.count != 32)
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func saveConfig() {
        errorMessage = nil
        saved = false
        do {
            try TokenStorage.save(token)
            let config = DeviceConfig(name: "Air Purifier", ipAddress: ip, protocolVersion: proto,
                                      city: city, aqicnToken: aqicnToken)
            ConfigStore.shared.save(config)
            WidgetCenter.shared.reloadAllTimelines()
            saved = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadExisting() {
        if let config = ConfigStore.shared.load() {
            if !config.ipAddress.isEmpty  { ip = config.ipAddress }
            proto = config.protocolVersion
            city  = config.city
            if !config.aqicnToken.isEmpty { aqicnToken = config.aqicnToken }
        }
        if let saved = try? TokenStorage.load(), !saved.isEmpty {
            token = saved
        }
    }
}
