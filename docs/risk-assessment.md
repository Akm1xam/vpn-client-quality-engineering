# Risk Assessment & Threat Modeling

## 1. Methodology

Risks are quantified using the Risk Priority Number (RPN) model:
$$\text{RPN} = \text{Probability} \times \text{Impact} \times \text{Detectability}$$

- **Probability (P)**: 1 (Very Rare) to 5 (Frequent)
- **Impact (I)**: 1 (Negligible) to 5 (Critical Data Loss / Security Compromise)
- **Detectability (D)**: 1 (Immediately visible in automated tests) to 5 (Silent failure in production)
- **Severity Classification**:
  - **Critical**: RPN $\ge 40$ or Impact = 5 (Immediate Release Blocker)
  - **High**: $24 \le \text{RPN} < 40$
  - **Medium**: $12 \le \text{RPN} < 24$
  - **Low**: $\text{RPN} < 12$

---

## 2. Risk Matrix

| Risk ID | Domain | Scenario | P | I | D | RPN | Severity | Mitigation Strategy | Test Coverage | Release Blocker |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- | :--- | :---: |
| **RISK-NET-001** | Connectivity | Tunnel reports `.connected`, but routing fails; traffic stalls or drops silently. | 3 | 5 | 4 | **60** | **Critical** | Implement active end-to-end ping & TCP probe upon connection establishment. | `NET-RES-001` | **YES** |
| **RISK-NET-002** | DNS | DNS requests bypass tunnel during Wi-Fi to Cellular handoff, leaking queries to ISP. | 3 | 5 | 4 | **60** | **Critical** | Configure strict `NEDNSSettings.matchDomains = [""]` and block direct port 53 egress. | `SEC-LEAK-001` | **YES** |
| **RISK-NET-003** | IPv6 | IPv6 traffic leaks outside tunnel on dual-stack networks when remote server is IPv4 only. | 4 | 5 | 3 | **60** | **Critical** | Route all IPv6 traffic to blackhole or drop interface unless remote server supports IPv6 outbound. | `NET-IP6-001` | **YES** |
| **RISK-MEM-001** | Memory | PacketTunnelExtension exceeds 15 MB resident memory budget, causing iOS kernel to kill process (`EXC_RESOURCE`). | 4 | 5 | 3 | **60** | **Critical** | Strip runtime symbols, tune Go GC via CGO bridge, disable disk logging in extension. | `PERF-MEM-001` | **YES** |
| **RISK-SEC-001** | Privacy | Sensitive credentials (passwords, UUIDs, Reality keys) printed to system logs. | 3 | 5 | 3 | **45** | **Critical** | Enforce `SanitizedLogger` regex masking and volatile in-memory circular ring buffer. | `SEC-LOG-001` | **YES** |
| **RISK-CONC-001**| Concurrency | Race condition between rapid Connect and Disconnect commands corrupts VPN state. | 4 | 4 | 2 | **32** | **High** | Encapsulate lifecycle state transitions inside `ConnectionCoordinator` Swift Actor. | `STATE-REC-001` | **YES** |
| **RISK-CFG-001** | Configuration | Malformed or unsupported Xray config item causes core crash during boot. | 3 | 4 | 2 | **24** | **High** | Pre-boot JSON schema validation in `XrayBridge.validate(jsonString:)` before calling start. | `FUN-CFG-002` | **YES** |
| **RISK-LIF-001** | Lifecycle | Device goes to sleep; on wake, TCP connections are dead, but tunnel state remains stuck. | 4 | 4 | 2 | **32** | **High** | Implement keepalive heartbeats and reconnect on `NWPathMonitor` interface change. | `NET-HND-001` | **YES** |
| **RISK-STR-001** | Storage | Keychain item access fails with error `-34018` during background extension execution. | 3 | 4 | 2 | **24** | **High** | Dual-persist credentials into isolated encrypted App Group credentials directory. | `INT-STR-001` | **YES** |
| **RISK-HWID-001**| Subscription | Remnawave anti-sharing lock blocks client due to missing or unstable `x-hwid` header. | 3 | 4 | 2 | **24** | **High** | Persist deterministic UUID in `AppGroupStorage.persistentHWID()` across updates. | `FUN-SUB-001` | **YES** |

---

## 3. Detailed Risk Analysis & Verification Plan

### 3.1 RISK-MEM-001: Packet Tunnel Memory Limit Exceeded
- **Description**: Apple does not provide a generous memory allowance for Network Extension targets. On constrained devices, extensions that consume >15 MB resident memory can be terminated without warning.
- **Root Cause**: Go runtime (cgo), goroutine allocations, and heavy buffered read/writes.
- **Verification**: 
  - Automation in `benchmarks/run_memory_benchmark.sh`.
  - Continuous measurement via Xcode Instruments (`Allocations` and `Memory Graph`).

### 3.2 RISK-NET-002: DNS Leakage During Interface Transition
- **Description**: When a device switches from Wi-Fi to 5G, iOS reconfigures network interfaces. If `NEPacketTunnelNetworkSettings` does not immediately re-bind DNS routes, standard DNS queries may egress to cellular carrier DNS resolvers.
- **Verification**: 
  - Packet inspection using Wireshark on test Wi-Fi router.
  - Automated DNS leak detection script `network-lab/scripts/check_dns_leak.sh`.

### 3.3 RISK-CONC-001: State Machine Race Conditions
- **Description**: Rapidly tapping the connect button or triggering a disconnect while an asynchronous connection handshake is pending can lead to mismatched states where the UI shows "Connected" but the tunnel is dead.
- **Verification**:
  - Swift Testing suite `StateTransitionInvariantsTests` running concurrent Task storms.

