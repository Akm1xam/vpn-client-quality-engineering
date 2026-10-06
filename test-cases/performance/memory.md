# Performance & Memory Test Cases

## PERF-MEM-001: Packet Tunnel Extension Resident Memory Budget (< 15 MB)
- **Priority**: P0 (Blocker)
- **Preconditions**:
  - Physical iOS device connected via USB with Xcode Instruments Profiler attached.
  - Target build configured in Release mode with compiler optimizations enabled.
- **Test Data**: Active VLESS Reality or Trojan gRPC server.
- **Steps**:
  1. Boot target device and launch Via application.
  2. Connect to VPN server node.
  3. Attach `Allocations` and `Activity Monitor` instruments specifically to the `com.via.vpn.PacketTunnel` extension PID.
  4. Measure Resident Memory (RSS) across four distinct phases:
     - Phase A: Idle immediately after boot (0 traffic).
     - Phase B: Active continuous traffic (10 Mbps throughput for 15 minutes).
     - Phase C: High burst traffic (50 Mbps throughput for 5 minutes).
     - Phase D: Post-burst idle (5 minutes recovery).
- **Expected Result**:
  - Resident memory remains strictly below the **15.0 MB project envelope** across all four phases.
  - No continuous unbounded memory slope (memory leak) observed.
- **Automation Candidate**: Benchmark Script / Instruments Trace (`benchmarks/run_memory_benchmark.sh`).

---

## PERF-STR-001: Rapid Connect / Disconnect Cycle Stress
- **Priority**: P1 (Critical)
- **Preconditions**:
  - Application running on iOS Simulator or Device.
- **Test Data**: Pre-configured mock or real server.
- **Steps**:
  1. Trigger 50 rapid connect and disconnect cycles sequentially with randomized delays (50ms – 300ms) between commands.
  2. Monitor `ConnectionCoordinator` state machine transitions for deadlocks or unhandled exceptions.
  3. Verify that all async Tasks terminate and no abandoned goroutines remain.
- **Expected Result**:
  - 100% of iterations complete without deadlock.
  - Final state is consistently `.disconnected`.
- **Automation Candidate**: Yes (`ViaTests/StateTransitionInvariantsTests.swift`).

