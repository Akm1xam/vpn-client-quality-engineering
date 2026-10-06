# Functional Test Cases: VPN Lifecycle

## FUN-VPN-001: Clean VPN Tunnel Establishment
- **Priority**: P0 (Blocker)
- **Preconditions**:
  - Application installed with valid VPN entitlements.
  - At least one active server configuration present in `ServerStore`.
  - Device connected to functional Wi-Fi network.
- **Test Data**: VLESS Reality server node (e.g. Frankfurt DE-04).
- **Steps**:
  1. Launch application and navigate to Home view.
  2. Select the target VLESS Reality server.
  3. Tap the central Connect button (`vpn_toggle_button`).
  4. Observe state transition indicators on the UI.
  5. Check active session details and latency graph.
- **Expected Result**:
  - State progresses through `preparing` -> `requestingPermission` -> `connecting` -> `connected`.
  - The UI button reflects connected state with green accent.
  - Active session reflects target server display name and host.
  - Outbound traffic routes successfully through the tunnel.
- **Automation Candidate**: Yes (`ViaTests/StateTransitionInvariantsTests.swift`).
- **Observability**: `SanitizedLogger` reports `"VPN session established with server"`.

---

## FUN-VPN-002: Clean VPN Tunnel Disconnection
- **Priority**: P0 (Blocker)
- **Preconditions**:
  - Application actively in `.connected` state with active session.
- **Test Data**: N/A
- **Steps**:
  1. Open application in connected state.
  2. Tap the central Disconnect button.
  3. Observe state progression and network interface restoration.
- **Expected Result**:
  - State transitions immediately to `disconnecting`, then `disconnected`.
  - Session end time is recorded in active session model.
  - Tunnel interface is torn down and direct routing is restored.
- **Automation Candidate**: Yes (`ViaTests/StateTransitionInvariantsTests.swift`).
- **Observability**: `SanitizedLogger` reports `"VPN session disconnected."`.

---

## FUN-VPN-003: Connection with Explicit Server vs Optimal Auto-Selection
- **Priority**: P1 (Critical)
- **Preconditions**:
  - `ServerStore` contains multiple servers with differing health scores (RTT latency).
- **Test Data**:
  - Server A: RTT 25ms (Health score: 25)
  - Server B: RTT 120ms (Health score: 120)
- **Steps**:
  1. Trigger `connect(server: nil)` without specifying an explicit server.
  2. Inspect target server selected by `ConnectionCoordinator`.
- **Expected Result**:
  - `ConnectionCoordinator` selects Server A due to lowest health selection score.
- **Automation Candidate**: Yes (Unit test with Mock ServerStore).

