import Foundation
import Security

enum TokenStorageError: Error { case notFound, failed(OSStatus) }

enum TokenStorage {
    private static let service = "com.aircheckapp"
    private static let account = "device-token"

    static func save(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData] = data
        let s = SecItemAdd(add as CFDictionary, nil)
        guard s == errSecSuccess else { throw TokenStorageError.failed(s) }
    }

    static func load() throws -> String {
        let query: [CFString: Any] = [
            kSecClass:        kSecClassGenericPassword,
            kSecAttrService:  service,
            kSecAttrAccount:  account,
            kSecReturnData:   true,
            kSecMatchLimit:   kSecMatchLimitOne
        ]
        var result: AnyObject?
        let s = SecItemCopyMatching(query as CFDictionary, &result)
        guard s == errSecSuccess,
              let d = result as? Data,
              let t = String(data: d, encoding: .utf8) else {
            throw s == errSecItemNotFound ? TokenStorageError.notFound : TokenStorageError.failed(s)
        }
        return t
    }

    static func delete() {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
