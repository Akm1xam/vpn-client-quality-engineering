# Traceability & Test Matrix

This matrix links architectural components, risk definitions, test levels, and automation status across the Via client codebase.

---

## 1. Traceability Matrix

| Test ID | Area | Requirement / Risk | Test Level | Platform | Automation Status | Priority | Covered Risks |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **FUN-VPN-001** | VPN Core | Clean connect lifecycle to valid server | Integration | Simulator / Device | **Automated (Swift Testing)** | P0 | `RISK-NET-001` |
| **FUN-VPN-002** | VPN Core | Clean disconnect and interface teardown | Integration | Simulator / Device | **Automated (Swift Testing)** | P0 | `RISK-CONC-001` |
| **FUN-CFG-001** | Config | Multi-node JSON array parsing (42+ nodes) | Unit | All (SPM) | **Automated (Swift Testing)** | P0 | `RISK-CFG-001` |
| **FUN-CFG-002** | Config | Rejection of malformed / corrupt configs | Unit | All (SPM) | **Automated (Swift Testing)** | P1 | `RISK-CFG-001` |
| **FUN-SUB-001** | Config | Remnawave `x-hwid` header generation | Unit | All (SPM) | **Automated (Swift Testing)** | P1 | `RISK-HWID-001` |
| **STATE-REC-001**| State | Connect-while-connecting race prevention | Unit / Integration | All (SPM) | **Automated (Swift Testing)** | P0 | `RISK-CONC-001` |
| **STATE-REC-002**| State | Disconnect-while-disconnecting invariance | Unit / Integration | All (SPM) | **Automated (Swift Testing)** | P1 | `RISK-CONC-001` |
| **STATE-REC-003**| State | Exponential backoff delay calculation | Unit | All (SPM) | **Automated (Swift Testing)** | P1 | `RISK-NET-001` |
| **NET-HND-001** | Network | Wi-Fi to Cellular handoff resilience | Network Chaos | Physical Device | **Manual / Device Lab** | P0 | `RISK-NET-001` |
| **NET-RES-001** | Network | Auto-reconnect after temporary packet loss | Network Chaos | Physical Device | **Manual / Device Lab** | P1 | `RISK-NET-001` |
| **SEC-LEAK-001**| Security| DNS query containment within tunnel | Security | Physical Device | **Automated Script / Lab** | P0 | `RISK-NET-002` |
| **SEC-IP6-001** | Security| IPv6 traffic leak prevention (dual-stack) | Security | Physical Device | **Automated Script / Lab** | P0 | `RISK-NET-003` |
| **SEC-LOG-001** | Privacy | Sensitive credential redaction in logs | Unit | All (SPM) | **Automated (Swift Testing)** | P0 | `RISK-SEC-001` |
| **SEC-TEL-001** | Privacy | Zero telemetry SDKs verification | Static Analysis | CI (macOS) | **Automated (Shell / Git)** | P0 | `RISK-SEC-001` |
| **PERF-MEM-001**| Perf | Extension memory footprint < 15 MB | Benchmark | Physical Device | **Benchmark Script / Lab** | P0 | `RISK-MEM-001` |
| **PERF-STR-001**| Perf | 50 rapid connect/disconnect cycles | Stress | Simulator / Device | **Automated (Swift Testing)** | P1 | `RISK-CONC-001` |
| **UI-CRIT-001** | UI | Connection toggle button state transitions | UI | iOS Simulator | **Automated (XCUITest)** | P1 | `RISK-CONC-001` |
| **UI-CRIT-002** | UI | Server selection and list rendering | UI | iOS Simulator | **Automated (XCUITest)** | P2 | `RISK-CFG-001` |
| **INT-STR-001** | Storage | Keychain error fallback to App Group | Integration | Simulator / macOS | **Automated (Swift Testing)** | P1 | `RISK-STR-001` |

