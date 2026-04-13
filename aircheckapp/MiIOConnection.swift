// aircheckapp/MiIOConnection.swift
import Foundation
import Network

protocol MiIOConnecting {
    var deviceId: UInt32 { get }
    var timestamp: UInt32 { get }
    func connect() async throws
    func send(method: String, params: [Any]) async throws -> [String: Any]
    func disconnect()
}

final class MiIOConnection: MiIOConnecting {
    private(set) var deviceId: UInt32 = 0
    private(set) var timestamp: UInt32 = 0
    private var connection: NWConnection?
    private let host: NWEndpoint.Host
    private let port: NWEndpoint.Port = 54321
    let token: Data
    private var messageId = 1

    init(host: String, token: String) {
        self.host = NWEndpoint.Host(host)
        self.token = Data(hexString: token) ?? Data(count: 16)
    }

    func connect() async throws {
        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
        connection = NWConnection(host: host, port: port, using: params)
        connection!.start(queue: .global())
        try await udpSend(MiIOPacket.helloPacket())
        let resp = try await receiveWithTimeout(seconds: 3)
        let parsed = try MiIOPacket.parse(resp, token: token)
        deviceId = parsed.deviceId
        timestamp = parsed.timestamp
    }

    func send(method: String, params: [Any] = []) async throws -> [String: Any] {
        let id = messageId; messageId += 1
        let payload = try JSONSerialization.data(
            withJSONObject: ["id": id, "method": method, "params": params])
        let packet = try MiIOPacket.buildPacket(
            deviceId: deviceId, timestamp: timestamp, token: token, payload: payload)
        do {
            return try await sendAndReceive(packet)
        } catch MiIOError.timeout {
            return try await sendAndReceive(packet)
        }
    }

    func disconnect() {
        connection?.cancel()
        connection = nil
    }

    private func sendAndReceive(_ packet: Data) async throws -> [String: Any] {
        try await udpSend(packet)
        let resp = try await receiveWithTimeout(seconds: 3)
        let parsed = try MiIOPacket.parse(resp, token: token)
        guard let json = parsed.json else { throw MiIOError.invalidPacket }
        return json
    }

    private func udpSend(_ data: Data) async throws {
        guard let conn = connection else { throw MiIOError.notConnected }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            conn.send(content: data, completion: .contentProcessed { err in
                if let err { cont.resume(throwing: err) } else { cont.resume() }
            })
        }
    }

    private func receiveWithTimeout(seconds: Double) async throws -> Data {
        guard let conn = connection else { throw MiIOError.notConnected }
        return try await withThrowingTaskGroup(of: Data.self) { group in
            group.addTask {
                try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
                    conn.receiveMessage { content, _, _, error in
                        if let error { cont.resume(throwing: error) }
                        else if let data = content { cont.resume(returning: data) }
                        else { cont.resume(throwing: MiIOError.invalidPacket) }
                    }
                }
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw MiIOError.timeout
            }
            guard let result = try await group.next() else { throw MiIOError.timeout }
            group.cancelAll()
            return result
        }
    }
}
