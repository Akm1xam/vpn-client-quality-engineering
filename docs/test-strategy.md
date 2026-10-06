# Test Strategy

## 1. Executive Summary

This Quality Engineering Strategy establishes the verification standards for the **Via** VPN client on iOS 17+ and macOS. The system under test (SUT) combines a modern Swift 6 user interface with Apple's `NetworkExtension` framework and a sandboxed Go-based proxy runtime (`Xray-core v1.8.24`).

Because VPN software operates at the operating system boundary, standard application testing practices are insufficient. This strategy prioritizes data-plane verification, memory footprint compliance, resilient connection state transitions, and zero-leak privacy validation.

---

## 2. Quality Objectives

| Objective | Description | Target Metric |
| :--- | :--- | :--- |
| **Tunnel Correctness** | Accurate routing of IP packets through specified proxy outbounds. | 100% of tested protocol configurations establish valid outbounds. |
| **Data Plane Privacy** | Complete prevention of DNS, IPv6, and WebRTC leakage outside the tunnel interface. | 0 unencrypted DNS queries or leaked IPv6 packets detected. |
| **Connection Resilience** | Deterministic state recovery across network interface changes and dropouts. | Automatic recovery within exponential backoff window without app crash. |
| **Memory Footprint** | Adherence to project memory budget in the packet extension. | Extension resident memory < 15 MB across all connection phases. |
| **Concurrency Safety** | Elimination of race conditions and deadlocks in multi-threaded workflows. | Swift 6 strict concurrency compliance with zero data races. |
| **Zero Telemetry** | Absolute absence of third-party tracking, analytics, or persistent plaintext logs. | 0 telemetry endpoints contacted; 100% sanitized in-memory logs. |

---

## 3. Test Levels & Methodology

```
               [ UI Tests (XCUITest) ]
              - End-to-end user flows
              - Server selection & toggle
              - Accessibility identifiers
                         ▲
            [ Network Chaos & Device Lab ]
           - Wi-Fi ↔ Cellular handoff
           - High latency & packet loss
           - Sleep / wake transitions
                         ▲
         [ Integration Tests (Swift Testing) ]
        - ConnectionCoordinator state transitions
        - RuntimeSnapshotManager atomic persistence
        - ServerStore Keychain fallback handling
                         ▲
           [ Unit Tests (Swift Testing) ]
          - UniversalConfigurationParser logic
          - XrayConfigCompiler stream builders
          - Exponential backoff retry policy
```

### 3.1 Unit Testing (Swift Testing)
- **Tooling**: Swift Testing (`@Test`, `#expect`, `#require`, `@Suite`).
- **Scope**: Pure functional logic, parsers, compilers, retry algorithms, model serialization.
- **Characteristics**: Highly isolated, deterministic, runs in under 1 second without network connectivity.

### 3.2 Integration Testing
- **Scope**: Interaction between actors (`ConnectionCoordinator`, `ServerStore`, `SettingsStore`) and filesystem/IPC boundaries (`AppGroupStorage`, `KeychainManager`).
- **Approach**: Executed against test doubles (mocks/stubs) to decouple tests from the Apple kernel `utun` interface.

### 3.3 UI Testing (XCUITest)
- **Tooling**: Apple `XCTest` / `XCUITest`.
- **Scope**: Critical user journeys: first launch, manual server addition, subscription update, toggle connection button, navigating settings.
- **Convention**: Relies strictly on semantic `accessibilityIdentifier` properties rather than coordinates or localized text labels.

### 3.4 Network Resilience Testing
- **Scope**: Packet loss, high latency, jitter, network interface switching (Wi-Fi ↔ LTE), captive portals, and DNS server timeouts.
- **Execution**: Controlled via macOS `pfctl`, Apple Network Link Conditioner, and physical router testbeds.

### 3.5 Security & Privacy Testing
- **Scope**:
  - Memory and log inspection for leaked credentials, UUIDs, or passwords.
  - Network traffic sniffing via Wireshark to confirm zero unencrypted DNS or IPv6 egress.
  - Dependency tree verification for unauthorized telemetry SDKs.

### 3.6 Performance & Longevity Testing
- **Scope**: Extension memory consumption over 1, 8, and 24-hour sessions; rapid connect/disconnect stress cycles (100 iterations); CPU usage during active 100 Mbps traffic throughput.

---

## 4. Test Environments & Constraints

| Environment | Capabilities | Limitations |
| :--- | :--- | :--- |
| **CI Runner (macOS / Xcode)** | Fast build, unit tests, parser integration tests, static security scans. | Cannot mount real kernel `utun` VPN interfaces; cannot execute cellular handoffs. |
| **iOS Simulator (macOS)** | Full UI execution, mocked tunnel connections via `ConnectionCoordinator`, fast iteration. | Cannot attach real `NEPacketTunnelProvider` network flow; shares host macOS network stack. |
| **Physical iOS Device (Lab)** | Real `NEPacketTunnelProvider` lifecycle, true cellular/Wi-Fi switching, real memory constraints. | Requires Apple Developer Provisioning, manual test harness setup, non-deterministic cellular signal. |
| **macOS Host** | Can run `XrayBridge` natively, execute network shaping with `pfctl`, monitor resident memory. | UI layout differs from iOS touch paradigms. |

---

## 5. Entry & Exit Criteria

### 5.1 Test Entry Criteria
- Code builds without compiler errors under Swift 6 strict concurrency (`-strict-concurrency=complete`).
- SPM tests pass locally (`swift test`).
- Test configuration fixtures contain valid, non-expired credentials on dedicated test infrastructure.

### 5.2 Test Exit Criteria (Release Readiness)
- 100% pass rate on the Core Smoke Suite.
- 0 open P0 (Blocker) or P1 (Critical) defects.
- Extension resident memory remains under 15 MB during 30-minute high-throughput test.
- No plaintext credentials detected in diagnostic logs.
- Signed validation run completed on physical iOS hardware.

