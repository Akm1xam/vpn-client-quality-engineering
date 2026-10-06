# Test Plan & Execution Matrix

## 1. Overview & Scope

This execution-oriented Test Plan defines the schedules, environments, and suites required to qualify builds of **Via** for release.

---

## 2. Test Execution Tiers

```
[ Tier 1: Pull Request Gate ]
  ├── Swift 6 Strict Concurrency Static Analysis
  ├── SPM Unit & Parser Test Suite (Fast: < 15s)
  └── Telemetry & Plaintext Secret Scans
          │
[ Tier 2: Nightly Automation ]
  ├── Full Regression Suite on Simulator (iPhone 18 Pro)
  ├── State Machine Race Condition Storms (100 iterations)
  └── XCUITest Critical Path Automation
          │
[ Tier 3: Pre-Release Device Lab ]
  ├── Physical iOS Device Tunnel Deployment
  ├── Wi-Fi ↔ Cellular Network Chaos Scenarios
  ├── 60-Minute Memory Envelope Verification (< 15 MB)
  └── Wireshark DNS / IPv6 Leak Audit
```

---

## 3. Test Suites

### 3.1 Smoke Test Suite (`SMOKE-REQ`)
Executed on every PR and build candidate.
- `FUN-VPN-001`: Clean connection to pre-configured VLESS Reality node.
- `FUN-VPN-002`: Clean disconnection and interface teardown.
- `FUN-CFG-001`: Parse multi-node JSON subscription and verify node count > 0.
- `SEC-LOG-001`: Diagnostic log sanitization audit.

### 3.2 Regression Test Suite (`REG-ALL`)
Executed prior to release tag creation.
- All functional tests across VLESS, Hysteria 2, Trojan, and Shadowsocks.
- App Group persistence and Keychain fallback validation.
- UI settings persistence (LAN Bypass, Custom DoH, Kill Switch).

### 3.3 Network Resilience Suite (`NET-RES`)
Executed in the physical device lab.
- Packet loss injection (1%, 5%, 20%, 50%).
- Latency injection (50ms, 200ms, 1000ms).
- Dynamic IP address change during streaming playback.
- Captive portal detection and user feedback.

### 3.4 Performance & Stress Suite (`PERF-STR`)
- `PERF-MEM-001`: Memory measurement during idle tunnel (target: < 15 MB).
- `PERF-MEM-002`: Memory measurement during continuous 50 Mbps file download.
- `PERF-STR-001`: 50 rapid Connect/Disconnect cycles in under 3 minutes.

---

## 4. Test Data & Fixtures

| Category | Fixture / Source | Description | Safety Consideration |
| :--- | :--- | :--- | :--- |
| **VLESS Reality** | `fixtures/vless_reality.json` | Sample configuration targeting lab gateway | Uses test-only dummy public keys. |
| **Hysteria 2** | `fixtures/hysteria2_sample.uri` | Hy2 link with UDP congestion settings | Points to RFC 5737 documentation prefix. |
| **Batch JSON** | `fixtures/flozvpn_batch.json` | Sanitized 42-node subscription array | Production server IPs replaced with test ranges. |
| **Malformed** | `fixtures/corrupted_config.json` | Syntax errors, missing UUID, invalid ports | Used strictly in negative unit tests. |

---

## 5. Roles & Responsibilities

- **SDET / Automation Engineer**: Maintain Swift Testing suites, XCUITest scripts, and CI workflows.
- **QA Lead**: Review test execution results, manage risk matrix, and sign off on release quality gates.
- **Developer**: Address blocking P0/P1 defects, preserve test doubles when refactoring production actors.

