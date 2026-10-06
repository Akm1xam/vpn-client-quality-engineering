import Testing
import Foundation
@testable import SharedCore
@testable import Domain
@testable import Storage
@testable import VPN
@testable import Configuration

@Suite("Security, Privacy & Log Sanitization Validation Tests")
struct SecurityAndPrivacyValidationTests {

    @Test("SanitizedLogger masks sensitive UUIDs, passwords, and Reality keys")
    func testLogSanitizerMasking() {
        SanitizedLogger.clearLogs()

        let sensitiveMsg = "Connecting vless://e88e285d-8524-4f27-b50a-e55541ff4ebc@198.51.100.1:443?pbk=MySecretPublicKey123&password=SecretPassword999"
        SanitizedLogger.shared.info(sensitiveMsg)

        let entries = SanitizedLogger.getRecentLogs()
        #expect(entries.count > 0)
        let lastEntry = entries.last?.message ?? ""

        // Validate that sensitive passwords and keys are redacted
        #expect(!lastEntry.contains("SecretPassword999"))
        #expect(!lastEntry.contains("MySecretPublicKey123"))
    }

    @Test("AppGroupStorage generates and persists a deterministic HWID")
    func testHWIDPersistence() {
        let storage = AppGroupStorage.shared
        let hwid1 = storage.persistentHWID()
        let hwid2 = storage.persistentHWID()

        #expect(!hwid1.isEmpty)
        #expect(hwid1 == hwid2, "HWID must be deterministic and identical across repeated invocations")
        #expect(hwid1.count >= 10 && hwid1.count <= 64, "HWID length must adhere to Remnawave regex /^[a-zA-Z0-9=-]{10,64}$/")
    }

    @Test("Zero telemetry SDK verification")
    func testZeroTelemetryCompliance() {
        // Prohibited telemetry framework classes that must never be linked in production binary
        let forbiddenSymbols = [
            "FIRAnalytics",
            "SentrySDK",
            "AppsFlyerTracker",
            "Mixpanel",
            "Amplitude"
        ]

        for symbol in forbiddenSymbols {
            let cls: AnyClass? = NSClassFromString(symbol)
            #expect(cls == nil, "Prohibited telemetry class '\(symbol)' must not be linked in production binary.")
        }
    }
}
