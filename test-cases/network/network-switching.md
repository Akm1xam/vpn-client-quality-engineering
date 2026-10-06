# Network Test Cases: Switching, Handoff & DNS

## NET-HND-001: Seamless Wi-Fi to Cellular Interface Handoff
- **Priority**: P0 (Blocker)
- **Preconditions**:
  - Physical iOS test device with active cellular data SIM card.
  - Device connected to test Wi-Fi network with active VPN tunnel.
  - Active TCP socket stream (e.g. continuous audio stream or long curl download).
- **Test Data**: Active VLESS Reality or Hysteria 2 proxy server.
- **Steps**:
  1. Verify active connection and traffic flowing over Wi-Fi interface.
  2. Disable Wi-Fi on the iOS device (Control Center toggle).
  3. Observe network route transition to LTE/5G.
  4. Verify whether tunnel connection drops, freezes, or recovers.
  5. Check whether any data packets or DNS queries bypass the tunnel during transition.
- **Expected Result**:
  - Xray core engine handles interface socket migration.
  - TCP stream continues without fatal app termination.
  - DNS requests continue routing strictly through configured tunnel DNS without leaking to cellular carrier.
- **Automation Candidate**: Device Lab / Manual testing (Requires physical cellular radio).

---

## NET-DNS-001: Strict DNS Tunnel Containment & Leak Prevention
- **Priority**: P0 (Blocker)
- **Preconditions**:
  - Test Wi-Fi router running packet sniffer (Wireshark or tcpdump on port 53 / 853).
  - Device connected to Via VPN with Cloudflare DoH (`1.1.1.1`) selected.
- **Test Data**: Unique disposable DNS test hostname (e.g. `probe-12345.dnsleaktest.com`).
- **Steps**:
  1. Start Wireshark capture on the Wi-Fi AP uplink interface.
  2. On the iOS device, trigger HTTP requests to the probe hostname.
  3. Stop capture and inspect packet logs for plaintext UDP/TCP port 53 packets containing the probe domain.
- **Expected Result**:
  - 0 plaintext DNS packets captured on physical Wi-Fi uplink.
  - All DNS resolution occurs through encrypted tunnel connection.
- **Automation Candidate**: Automated Script (`network-lab/scripts/check_dns_leak.sh`).

---

## NET-REC-001: Exponential Backoff Reconnect Resilience
- **Priority**: P1 (Critical)
- **Preconditions**:
  - Device connected to VPN.
- **Test Data**: Controllable upstream test proxy server.
- **Steps**:
  1. Terminate upstream proxy server process to simulate remote server crash.
  2. Observe `ConnectionCoordinator` handling of disconnection.
  3. Verify reconnect attempt intervals against `RetryPolicy.delay(forAttempt:)`.
  4. Restore upstream proxy server on attempt 2.
- **Expected Result**:
  - First reconnect attempted at ~1.0s.
  - Second reconnect attempted at ~2.0s with successful reconnection.
  - State returns to `.connected` without user intervention.
- **Automation Candidate**: Yes (`ViaTests/StateTransitionInvariantsTests.swift`).

