# Scenario: Packet Loss Resilience

## 1. Description
Simulates severe wireless transmission degradation and censorship-induced packet drops by injecting synthetic packet loss between the iOS client and the upstream proxy server.

---

## 2. Parameter Matrix

| Profile | Packet Loss | Target Protocol | Expected Behavior |
| :--- | :---: | :--- | :--- |
| **Low Loss** | 1% | VLESS (TCP), Trojan | No noticeable user degradation; standard TCP retransmissions handle drops. |
| **Medium Loss** | 5% | VLESS, Hysteria 2 | Hysteria 2 Brutal Congestion retains >80% bandwidth; TCP protocols throttle slightly. |
| **High Loss** | 20% | VLESS, Hysteria 2 | TCP connections suffer latency spikes; Hy2 UDP stream remains stable. |
| **Extreme Loss** | 50% | All Protocols | Latency indicator increases; `ConnectionCoordinator` holds tunnel without crashing. |

---

## 3. macOS Reproduction Procedure (dummynet / pfctl)

```bash
# 1. Create packet shaping pipe with 20% packet drop
sudo dnctl pipe 1 config plr 0.20

# 2. Assign pipe to outgoing proxy traffic
echo "dummynet out proto tcp to any port 443 pipe 1" | sudo pfctl -f - -e

# 3. Restore to clean state (Safety command)
sudo pfctl -d && sudo dnctl -q flush
```

---

## 4. Verification Checkpoints
- [ ] UI remains responsive throughout packet loss injection.
- [ ] Tunnel extension does not crash with `SIGPIPE` or out-of-memory errors.
- [ ] Real-time throughput graph reflects degradation without UI freeze.

