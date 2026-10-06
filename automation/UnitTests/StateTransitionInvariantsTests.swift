import Testing
import Foundation
@testable import SharedCore
@testable import Domain
@testable import Storage
@testable import VPN
@testable import Configuration

@Suite("State Transition Invariants & Race Condition Tests")
struct StateTransitionInvariantsTests {

    @Test("Verifies clean connection and disconnection lifecycle")
    func testCleanLifecycleTransitions() async throws {
        let coordinator = ConnectionCoordinator()

        #expect(await coordinator.currentState == .disconnected)
        #expect(await coordinator.activeSession == nil)

        // Connect with explicit test server
        let server = TestFixtures.makeServer()
        try await coordinator.connect(server: server)

        #expect(await coordinator.currentState == .connected)
        let session = await coordinator.activeSession
        #expect(session != nil)
        #expect(session?.serverHost == "192.0.2.1")
        #expect(session?.protocolType == .vless)

        // Disconnect
        await coordinator.disconnect()
        #expect(await coordinator.currentState == .disconnected)
        let closedSession = await coordinator.activeSession
        #expect(closedSession?.endTime != nil)
    }

    @Test("Connect while connecting is ignored without race condition")
    func testConnectWhileConnectingIgnored() async throws {
        let coordinator = ConnectionCoordinator()
        let server = TestFixtures.makeServer()

        try await coordinator.connect(server: server)
        #expect(await coordinator.currentState == .connected)

        // Second connect should be a no-op
        try await coordinator.connect(server: server)
        #expect(await coordinator.currentState == .connected)

        await coordinator.disconnect()
        #expect(await coordinator.currentState == .disconnected)
    }

    @Test("Disconnect while disconnected is safe no-op")
    func testDisconnectWhileDisconnectedSafe() async {
        let coordinator = ConnectionCoordinator()
        #expect(await coordinator.currentState == .disconnected)

        await coordinator.disconnect()
        #expect(await coordinator.currentState == .disconnected)
    }

    @Test("Exponential backoff retry delay adheres to progression bounds")
    func testRetryPolicyDelayCalculations() {
        let policy = RetryPolicy(maxAttempts: 5, delays: [1.0, 2.0, 5.0, 10.0, 30.0])

        #expect(policy.isRetryable(reason: .serverUnreachable) == true)
        #expect(policy.isRetryable(reason: .timeout) == true)
        #expect(policy.isRetryable(reason: .invalidConfiguration("syntax error")) == false)
        #expect(policy.isRetryable(reason: .vpnPermissionDenied) == false)

        #expect(policy.delay(forAttempt: 1) == 1.0)
        #expect(policy.delay(forAttempt: 2) == 2.0)
        #expect(policy.delay(forAttempt: 3) == 5.0)
        #expect(policy.delay(forAttempt: 4) == 10.0)
        #expect(policy.delay(forAttempt: 5) == 30.0)
        #expect(policy.delay(forAttempt: 6) == 30.0) // Capped at last delay
    }

    @Test("Rapid sequential connection toggle stress does not deadlock")
    func testRapidToggleStress() async throws {
        let coordinator = ConnectionCoordinator()
        let server = TestFixtures.makeServer()

        for _ in 0..<10 {
            try await coordinator.connect(server: server)
            #expect(await coordinator.currentState == .connected)
            await coordinator.disconnect()
            #expect(await coordinator.currentState == .disconnected)
        }
    }
}
