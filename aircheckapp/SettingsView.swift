import SwiftUI
import WidgetKit

struct SettingsView: View {
    @State private var name  = ""
    @State private var ip    = ""
    @State private var token = ""
    @State private var proto = DeviceConfig.ProtocolVersion.miOT
    @State private var saved = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Zariadenie") {
                    TextField("Meno (napr. Obývačka)", text: $name)
                    TextField("IP adresa (192.168.x.x)", text: $ip)
                        .keyboardType(.numbersAndPunctuation)
                }
                Section {
                    TextField("32-znakový hex token", text: $token)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    Text("Token získaš cez:\npip install python-miio\nmiiocli cloud")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Token")
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
                        .disabled(name.isEmpty || ip.isEmpty || token.count != 32)
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
            let config = DeviceConfig(name: name, ipAddress: ip, protocolVersion: proto)
            ConfigStore.shared.save(config)
            WidgetCenter.shared.reloadAllTimelines()
            saved = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadExisting() {
        if let config = ConfigStore.shared.load() {
            name  = config.name
            ip    = config.ipAddress
            proto = config.protocolVersion
        }
        token = (try? TokenStorage.load()) ?? ""
    }
}
