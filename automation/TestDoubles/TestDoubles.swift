import Foundation
import NetworkExtension
@testable import SharedCore
@testable import Domain
@testable import Storage
@testable import VPN

/// Test double simulating Apple's NETunnelProviderManager and connection state.
public final class MockTunnelManager: @unchecked Sendable {
    public var startCalled: Bool = false
    public var stopCalled: Bool = false
    public var shouldThrowOnStart: Bool = false

    public init() {}

    public func simulateStart() throws {
        if shouldThrowOnStart {
            throw NSError(domain: "MockTunnel", code: 101, userInfo: [NSLocalizedDescriptionKey: "Permission denied or tunnel failure."])
        }
        startCalled = true
    }

    public func simulateStop() {
        stopCalled = true
    }
}

/// In-memory fake implementation of AppGroupStorage for unit and integration testing.
public final class FakeAppGroupStorage: @unchecked Sendable {
    private var inMemoryFiles: [String: Data] = [:]
    private let lock = NSLock()

    public init() {}

    public func write(data: Data, toRelativePath path: String) {
        lock.lock()
        defer { lock.unlock() }
        inMemoryFiles[path] = data
    }

    public func read(fromRelativePath path: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return inMemoryFiles[path]
    }

    public func fileExists(atRelativePath path: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return inMemoryFiles[path] != nil
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        inMemoryFiles.removeAll()
    }
}

/// Test double generating deterministic test servers and configurations.
public enum TestFixtures {
    public static func makeServer(
        id: UUID = UUID(),
        name: String = "Test-Frankfurt-DE",
        host: String = "192.0.2.1",
        port: Int = 443,
        protocolType: ProxyProtocol = .vless,
        transport: TransportType = .tcp,
        security: SecurityType = .reality,
        flow: FlowType = .xtlsRprxVision,
        credentialKey: String = "secret:test-uuid-secret-12345",
        score: Double = 25.0
    ) -> Server {
        var server = Server(
            id: id,
            displayName: name,
            host: host,
            port: port,
            protocolType: protocolType,
            transport: transport,
            security: security,
            flow: flow,
            credentialKey: credentialKey,
            sni: "de01.flozvpn.net",
            realityOptions: RealityOptions(
                publicKey: "test_public_key_abc123",
                shortId: "0123456789abcdef"
            )
        )
        server.health.recordSuccess(latencyMs: Int(score))
        return server
    }

    public static func makeAppSettings(lanBypass: Bool = true) -> AppSettings {
        var settings = AppSettings()
        settings.routingProfile.allowLocalNetwork = lanBypass
        return settings
    }
}
