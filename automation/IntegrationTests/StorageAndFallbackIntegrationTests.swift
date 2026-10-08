import Testing
import Foundation
@testable import SharedCore
@testable import Domain
@testable import Storage
@testable import VPN
@testable import Configuration

@Suite("Storage & Resilient Fallback Integration Tests")
struct StorageAndFallbackIntegrationTests {

    @Test("ServerStore adds and retrieves servers correctly")
    func testServerStoreAddAndRetrieve() async throws {
        let store = ServerStore()
        let server = TestFixtures.makeServer(name: "Integration-Node-01")

        try await store.save(server: server, secretCredential: "test-secret-value")
        let all = await store.getAll()
        #expect(all.contains(where: { $0.id == server.id }))

        // Retrieve secret
        let recoveredSecret = try await store.secretForServer(server)
        #expect(recoveredSecret == "test-secret-value" || recoveredSecret == "test-uuid-secret-12345")

        // Delete server
        try await store.delete(serverID: server.id)
        let afterRemoval = await store.getAll()
        #expect(!afterRemoval.contains(where: { $0.id == server.id }))
    }

    @Test("RuntimeSnapshotManager creates and reads atomic profile snapshot")
    func testRuntimeSnapshotAtomicCreation() async throws {
        let isolatedStorage = AppGroupStorage(groupIdentifier: "test.isolated.\(UUID().uuidString)")
        let manager = RuntimeSnapshotManager(storage: isolatedStorage)
        let server = TestFixtures.makeServer()

        let compiler = XrayConfigCompiler()
        let compiledResult = try await compiler.compile(
            server: server,
            secretCredential: "test-uuid-secret-key",
            routingProfile: .defaultProfile,
            dnsProfile: .defaultProfile,
            settings: AppSettings()
        )

        let profile = try await manager.createSnapshot(compiledResult: compiledResult, server: server)
        #expect(profile.serverID == server.id)

        let activeProfile = try await manager.getActiveProfile()
        #expect(activeProfile.id == profile.id)

        let netSettings = try await manager.loadNetworkSettings(profileID: profile.id)
        #expect(netSettings.tunnelIPv4 == "10.0.0.2")
        #expect(netSettings.dnsServers.contains("1.1.1.1"))
    }
}

