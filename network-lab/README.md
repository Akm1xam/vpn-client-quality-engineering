# Network Chaos Lab & Fault Injection

## 1. Overview

The Network Chaos Lab defines reproducible physical and synthetic fault-injection scenarios to test the resilience of **Via** under degraded network conditions.

The lab tests four primary failure modes:
1. **Packet Loss**: 1%, 5%, 20%, 50%.
2. **Artificial Latency**: 50ms, 150ms, 500ms, 1000ms.
3. **Jitter & Out-of-Order Packets**: $\pm 20$ms, $\pm 100$ms.
4. **Interface Flapping & Blackholing**: Instantaneous loss of default route.

---

## 2. Lab Infrastructure Setup

```
[ Developer Host / Router ]
     │  (macOS pfctl / Linux netem / dummynet)
     ▼
[ Managed Test Wi-Fi AP ]
     │  (WPA3, Dual-Band 2.4/5GHz)
     ▼
[ Physical iOS Device SUT ] ─── (Real Cellular 4G/5G)
     │
     ▼
[ Uplink Gateway ] ─── [ Controlled Xray Test Outbounds ]
```

---

## 3. Scenarios Catalog

- `scenarios/packet-loss.md`: Resilience under 1% to 50% packet drop rates.
- `scenarios/high-latency.md`: Behavioral validation across transoceanic latencies (500ms – 1000ms).
- `scenarios/network-drop.md`: Sudden disconnection, sleep/wake, and airplane mode recovery.
- `scenarios/dns-failure.md`: Simulating upstream DoH outages and resolver fallbacks.
- `scenarios/reconnect-storm.md`: Handling rapid server restarts and connection floods.

---

## 4. Safety Policy

> [!CAUTION]
> Automated scripts in `network-lab/scripts/` **NEVER** apply persistent kernel packet filter (`pfctl`) rules without an automatic timeout rollback. If a script loses terminal connectivity, all firewall rules reset within 60 seconds.

