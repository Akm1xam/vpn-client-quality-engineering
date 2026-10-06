# Release Quality Gates & Criteria

## 1. Quality Gates Overview

A build of **Via** may only transition to Production / App Store distribution when all quality gates defined below are satisfied.

```
       [ GATE 1: Static Checks & Concurrency ]
      - Swift 6 strict concurrency checks: 0 warnings
      - Static telemetry scan: 0 trackers detected
                         │
                         ▼
        [ GATE 2: Automated CI Test Suites ]
      - Unit & Integration pass rate: 100%
      - State machine stress suite: 0 race conditions
                         │
                         ▼
        [ GATE 3: Performance & Memory Budget ]
      - Extension resident memory: < 15 MB envelope
      - Connection handshake latency: within baseline
                         │
                         ▼
        [ GATE 4: Device Lab & Security Audit ]
      - Zero DNS leaks across Wi-Fi / LTE handoff
      - 0 open P0 (Blocker) or P1 (Critical) defects
```

---

## 2. Severity Classification & Gate Thresholds

### 2.1 P0 Defects (Blocker)
- **Definition**: Tunnel fails to connect; user traffic unencrypted outside tunnel; extension killed due to memory limit; app crashes on launch; sensitive passwords logged in plaintext.
- **Release Threshold**: **Strictly 0 allowed.**

### 2.2 P1 Defects (Critical)
- **Definition**: Automatic reconnect loop after network drops; DNS resolution fails for specific domains; HWID lock rejection from supported panel; localized UI freeze during configuration import.
- **Release Threshold**: **0 allowed without signed mitigation waiver from Project Lead.**

### 2.3 P2 Defects (Major)
- **Definition**: Non-critical UI glitch in Dark/Light mode; cosmetic latency graph jitter; non-breaking delay in subscription metadata refresh.
- **Release Threshold**: $\le 3$ known issues documented in release notes.

---

## 3. Quantitative Criteria

| Quality Dimension | Metric | Required Threshold | Verification Method |
| :--- | :--- | :--- | :--- |
| **Unit Test Coverage** | Executed test cases in SPM | 100% passing tests | `swift test` |
| **Smoke Suite** | Core connection flows | 100% pass rate | CI PR Workflow |
| **Extension Memory** | Resident memory (RSS) in Tunnel | **< 15.0 MB project envelope** | Xcode Instruments / Memory Benchmark |
| **Main App Memory** | Resident memory (RSS) in UI App | **< 60.0 MB** | Memory Benchmark |
| **Data Plane Privacy** | Unencrypted DNS queries | **0 detected queries** | Wireshark Packet Audit |
| **Log Sanitization** | Sensitive keywords in system logs | **0 instances of unmasked secrets** | Automated log scanner |
| **Reconnect Resilience** | Auto-recovery after 10s network loss | Recovery within exponential backoff window | Device Lab Network Chaos |
| **Telemetry Footprint** | External analytics dependencies | **0 third-party analytics libraries** | Dependency graph audit |

---

## 4. Device Lab Sign-Off Matrix

Prior to submission, testing must be completed on at least two physical hardware tiers:

- [ ] **Tier A**: iPhone running latest iOS release (e.g., iPhone 15/16/17 running iOS 18+).
- [ ] **Tier B**: Older supported iPhone running baseline iOS (e.g., iPhone 11/12 running iOS 17.0).
- [ ] **Tier C**: Apple Silicon Mac running macOS Sonoma / Sequoia.

