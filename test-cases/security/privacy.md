# Security & Privacy Test Cases

## SEC-LOG-001: Redaction of Sensitive Credentials in Logs
- **Priority**: P0 (Blocker)
- **Preconditions**:
  - `SanitizedLogger` instantiated.
- **Test Data**: Strings containing reality public keys, passwords, UUIDs, and private tokens.
- **Steps**:
  1. Emit log message with query parameters: `vless://uuid-secret-12345@1.2.3.4:443?pbk=my-secret-reality-key&password=secretpass`.
  2. Retrieve stored log records from in-memory ring buffer.
  3. Inspect log content for presence of `uuid-secret-12345` or `my-secret-reality-key`.
- **Expected Result**:
  - Sensitive values are replaced with masked placeholders (`REDACTED`).
  - No raw secret values exist in memory or console stream.
- **Automation Candidate**: Yes (`ViaTests/SecurityAndPrivacyValidationTests.swift`).

---

## SEC-STR-001: Resilient Keychain Storage & Fallback Encryption
- **Priority**: P1 (Critical)
- **Preconditions**:
  - Device running in an environment where Keychain access may be restricted or locked (e.g. background execution before first user unlock).
- **Test Data**: Server configuration with sensitive password credentials.
- **Steps**:
  1. Trigger server store persist operation.
  2. Simulate Keychain failure with OSStatus `-34018`.
  3. Verify whether credential is dropped or written to fallback credentials directory.
  4. Retrieve credential via `secretForServer(_:)`.
- **Expected Result**:
  - `ServerStore` falls back to encrypted file storage under App Group container.
  - Secret is successfully recovered without failing the connection lifecycle.
- **Automation Candidate**: Yes (`ViaTests/StorageAndFallbackIntegrationTests.swift`).

---

## SEC-TEL-001: Verification of Zero External Telemetry SDKs
- **Priority**: P0 (Blocker)
- **Preconditions**:
  - Project source tree and `Package.swift`.
- **Test Data**: List of prohibited SDK names (Firebase, Sentry, Mixpanel, AppsFlyer, Amplitude, TelemetryDeck).
- **Steps**:
  1. Run recursive dependency and symbol scan across all targets in `Via.xcodeproj` and `Package.swift`.
  2. Inspect dynamic framework links in build artifacts.
- **Expected Result**:
  - 0 matches found for prohibited telemetry providers.
  - No network connections initiated on launch other than user-specified VPN endpoints.
- **Automation Candidate**: Yes (`ViaTests/SecurityAndPrivacyValidationTests.swift`).

