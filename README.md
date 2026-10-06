# Via — VPN Client Quality Engineering

Quality Engineering framework for an Apple NetworkExtension VPN client built with Swift 6 and Xray-core.

<p align="left">
  <a href="#test-matrix"><img src="https://img.shields.io/badge/Test%20Suites-16%20Passing-10b981?style=flat-square&logo=apple&logoColor=white" alt="Tests" /></a>
  <a href="#test-matrix"><img src="https://img.shields.io/badge/Framework-Swift%20Testing-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift Testing" /></a>
  <a href="#quality-gates"><img src="https://img.shields.io/badge/Memory%20Budget-%3C%2015%20MB-38bdf8?style=flat-square" alt="Memory Budget" /></a>
  <a href="#security-verification"><img src="https://img.shields.io/badge/Privacy-0%20DNS%20Leaks-8b5cf6?style=flat-square" alt="Zero Leaks" /></a>
  <a href="#security-verification"><img src="https://img.shields.io/badge/Telemetry-0%20Trackers-10b981?style=flat-square" alt="Zero Telemetry" /></a>
</p>

---

### Engineering Predictability for Unpredictable Networks

The **Via Quality Engineering Framework** is a testing subsystem designed for an Apple `NetworkExtension` VPN client. Operating at the boundary between user space and the Darwin kernel, it prioritizes **data-plane isolation**, **deterministic actor state invariants**, **sub-15 MB memory budget compliance**, and **resilience in hostile network conditions**.

---

## Architecture & System Under Test (SUT)

```
Via Application (SwiftUI / Host Process)
├── Presentation Layer (DesignSystem / Feature Views)
├── Domain Model Layer (Server, RoutingProfile, DNSProfile, Source)
├── Storage Layer (ServerStore, SourceStore, SettingsStore Actors)
├── Configuration Layer (UniversalConfigurationParser, SourceUpdater with HWID)
└── VPN Orchestration Layer (ConnectionCoordinator Actor, XrayConfigCompiler, RuntimeSnapshotManager)
        │
        ├── IPC via App Group (`group.com.via.vpn`) & Shared Keychain
        │
Packet Tunnel Extension (NEPacketTunnelProvider / Separate Process)
├── System Tunnel Configuration (NEPacketTunnelNetworkSettings)
├── Virtual Interface Binding (NEPacketTunnelFlow)
├── Low-Level Bridge (XrayBridge C/cgo interface)
└── Pinned Proxy Core (Xray-core v1.8.24)
        │
Outbound Proxy Nodes (VLESS Reality, Hysteria 2, Trojan gRPC, Shadowsocks 2022)
```

---

## Verification Pipeline & Test Pyramid

Rather than relying on brittle UI automation, Via structures testing around operating-system boundaries:

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

### The 4 Verification Layers

1. **Tier 1: Unit Invariants (50%)** — *Swift Testing (`@Suite`, `@Test`, `#expect`)*
   - Fast sub-second execution (0.069s) requiring no network interfaces.
   - Validates multi-node batch parsers, Xray stream setting compilers, and exponential backoff retry math.
   - Guards against lifecycle race conditions (e.g. `connect-while-connecting` and `disconnect-while-disconnecting`).
2. **Tier 2: Component Integration (30%)** — *Actors & Test Doubles*
   - Verifies state handoffs across `ConnectionCoordinator`, `ServerStore`, and `RuntimeSnapshotManager`.
   - Tests atomic packaging of `xray.json` configurations into the shared App Group container.
   - Exercises the Keychain dual-persist fallback when sandboxed background extensions encounter error `-34018`.
3. **Tier 3: User Journey Automation (10%)** — *Apple XCUITest*
   - Navigates critical user flows using semantic `accessibilityIdentifier` tokens.
   - Verifies connection toggle button states, server list rendering, and user-facing privacy guarantees.
4. **Tier 4: Network Chaos Lab (10%)** — *Physical Hardware & Fault Injection*
   - Real-world simulation of packet loss (1% to 50%), transoceanic latency, jitter, and interface migration.
   - Non-destructive network scripts and Wireshark uplink sniffer audits to ensure zero unencrypted DNS leaks.

---

## Quick Start: Running Tests

```bash
# 1. Clean extended attributes and execute complete test suite
xattr -c -r Sources Tests Targets vpn-client-quality-engineering Package.swift 2>/dev/null
swift test

# 2. Run tests in Xcode for iOS Simulator (iPhone 18 Pro)
xcodebuild test -scheme Via -destination 'platform=iOS Simulator,name=iPhone 18 Pro'

# 3. Execute non-destructive DNS audit script
./network-lab/scripts/check_dns_leak.sh

# 4. Measure resident memory of target process
./benchmarks/run_memory_benchmark.sh
```

---

## Automated Test Catalog

| Test Identifier | Category | Area | Invariant Verified | Tooling |
| :--- | :--- | :--- | :--- | :--- |
| **`testCleanLifecycleTransitions`** | State Machine | `VPN/State` | Clean `.disconnected` ➔ `.connected` ➔ `.disconnected` progression | Swift Testing |
| **`testConnectWhileConnectingIgnored`**| Concurrency | `VPN/State` | Concurrent connect command is an idempotent no-op | Swift Testing |
| **`testDisconnectWhileDisconnectedSafe`**| Concurrency | `VPN/State` | Redundant disconnect commands are safe no-ops | Swift Testing |
| **`testRetryPolicyDelayCalculations`** | Reliability | `VPN/State` | Exponential backoff capped progression: 1s, 2s, 5s, 10s, 30s | Swift Testing |
| **`testRapidToggleStress`** | Concurrency | `VPN/State` | 10 rapid connect/disconnect cycles under actor isolation without deadlocks | Swift Testing |
| **`testLogSanitizerMasking`** | Security | `SharedCore` | Regex redaction of UUIDs, passwords, and Reality keys in logs | Swift Testing |
| **`testHWIDPersistence`** | Subscriptions | `SharedCore` | Deterministic `x-hwid` signature conforming to `/^[a-zA-Z0-9=-]{10,64}$/` | Swift Testing |
| **`testZeroTelemetryCompliance`** | Privacy | `ViaApp` | Dynamic reflection audit: 0 tracking SDK symbols linked | Swift Testing |
| **`testServerStoreAddAndRetrieve`** | Integration | `Storage` | Actor-isolated server save, retrieve, and secret recovery | Swift Testing |
| **`testRuntimeSnapshotAtomicCreation`**| Integration | `VPN/Compiler`| Atomic `xray.json` and network settings snapshot generation | Swift Testing |
| **`CriticalUserJourneyUITests`** | End-to-End | `UITests` | App launch, server list rendering, and privacy bullet verification | XCUITest |

---

## Quality Gates & Thresholds

Every pull request and build candidate is evaluated against strict, non-negotiable release criteria:

```
[ Gate 1: Static Concurrency ] ──► Swift 6 strict concurrency checks (0 warnings)
                                    └── Telemetry scanner (0 tracking frameworks)
[ Gate 2: Automated Tests ]    ──► 100% pass rate across all unit and integration tests
[ Gate 3: Memory Envelope ]    ──► PacketTunnelExtension resident memory < 15.0 MB
[ Gate 4: Security & Leakage ] ──► 0 plaintext credentials in logs; 0 DNS leaks
```

- **P0 Defects**: **Strictly 0 allowed.** (Blocks release immediately).
- **P1 Defects**: **0 allowed without signed mitigation.**
- **Project Memory Budget**: Extension memory must remain within the **< 15 MB envelope** during 60-minute stress tests.

---

## CI vs. Device Lab Boundaries

Because Apple's `NetworkExtension` framework interacts directly with the Darwin kernel and system privileges, tests are explicitly partitioned by execution capability:

| Capability | CI-Compatible (Automated on GitHub Runner) | Device Lab (Physical Hardware Required) |
| :--- | :---: | :---: |
| **Swift 6 Actor Concurrency & State Invariants** | ✅ Automated (`swift test`) | — |
| **Multi-node JSON Subscription Parsing** | ✅ Automated (`swift test`) | — |
| **In-Memory Log Sanitization & Redaction** | ✅ Automated (`swift test`) | — |
| **Static Telemetry SDK Scanner** | ✅ Automated (`qa-quality-gates.yml`) | — |
| **Simulated VPN Session Transitions** | ✅ Automated (`ViaTests`) | — |
| **Native `NEPacketTunnelProvider` Kernel Binding** | ❌ Not CI-compatible | ✅ Physical iOS 17/18 Device |
| **Physical Wi-Fi ↔ 5G Cellular Network Handoff** | ❌ Not CI-compatible | ✅ Physical iOS Device + SIM |
| **Router-Level Packet Capture (DNS Leaks)** | ❌ Not CI-compatible | ✅ Wi-Fi AP + Wireshark Uplink |
| **60-Minute Resident Memory Profiling** | ❌ Not CI-compatible | ✅ Xcode Instruments attached to PID |
| **Physical Device Sleep/Wake Network Recovery** | ❌ Not CI-compatible | ✅ Manual Lab Verification |

---

## Repository Structure

```
vpn-client-quality-engineering/
├── .github/workflows/                 # CI quality gate workflow definitions
├── README.md                          # Quality Engineering architecture & overview
├── automation/
│   ├── IntegrationTests/              # Component boundary tests (Actor IPC, Snapshots)
│   ├── TestDoubles/                   # MockTunnelManager, FakeAppGroupStorage, TestFixtures
│   ├── UITests/                       # XCUITest critical user journey automation
│   └── UnitTests/                     # Swift Testing invariants & security verification
├── benchmarks/                        # Memory benchmark scripts and JSON schemas
├── docs/
│   ├── release-criteria.md            # Quantitative quality gates & defect thresholds
│   ├── risk-assessment.md             # RPN risk matrix & threat model
│   ├── test-matrix.md                 # Traceability matrix mapping risks to tests
│   ├── test-plan.md                   # Execution plan (Smoke, Regression, Chaos)
│   └── test-strategy.md               # End-to-end test philosophy & objectives
├── network-lab/
│   ├── scenarios/                     # Documented fault-injection scenarios (loss, latency)
│   └── scripts/                       # Non-destructive DNS audit & measurement scripts
├── reports/
│   ├── sanitized-samples/             # Production-safe defect investigation samples
│   └── templates/                     # Standardized defect report templates
└── test-cases/                        # Functional, network, performance, and security specs
```

---

## License & Attribution

- Part of the **Via** project, licensed under the [Mozilla Public License 2.0 (MPL-2.0)](../LICENSE).
- Pinned Xray proxy runtime powered by [Xray-core](https://github.com/XTLS/Xray-core) (MPL-2.0).
