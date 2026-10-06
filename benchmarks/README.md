# Performance Benchmarking Methodology

## 1. Objectives & Principles

The performance benchmarking suite measures resource utilization, memory boundaries, and connection establishment latencies across both the main iOS host application and the `NEPacketTunnelProvider` extension.

> [!IMPORTANT]
> **No Fictitious Benchmarks**: All metrics in this directory define rigorous methodologies and JSON schemas. Baseline numbers are recorded only when executed against real hardware. Unmeasured metrics are explicitly marked as `Baseline Pending`.

---

## 2. Core Metrics & Budgets

| Metric | Target Process | Engineering Target | Status | Tooling |
| :--- | :--- | :--- | :--- | :--- |
| **Extension Memory Footprint (Idle)** | `PacketTunnel` | **< 15.0 MB** | Baseline Pending | Xcode Instruments / `vmmap` |
| **Extension Memory Footprint (Active 50 Mbps)** | `PacketTunnel` | **< 15.0 MB** | Baseline Pending | Xcode Instruments / `vmmap` |
| **Main App Memory Footprint (Idle)** | `ViaApp` | **< 60.0 MB** | Baseline Pending | Xcode Instruments |
| **Connection Latency (Handshake RTT)** | Host to Proxy | **Min, Median, p95, Max** | Baseline Pending | Benchmark Harness |
| **CPU Utilization (Idle Connected)** | Both Processes | **< 2%** | Baseline Pending | Xcode Instruments |

---

## 3. Memory Measurement Schema (JSON)

When benchmarks are executed on physical hardware, results must be logged in `benchmarks/results/` following this JSON schema:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ViaMemoryBenchmarkResult",
  "type": "object",
  "properties": {
    "timestamp": { "type": "string", "format": "date-time" },
    "device": { "type": "string" },
    "os_version": { "type": "string" },
    "build_configuration": { "type": "string", "enum": ["Release", "Debug"] },
    "protocol": { "type": "string" },
    "duration_seconds": { "type": "integer" },
    "throughput_mbps": { "type": "number" },
    "extension_memory_mb": {
      "type": "object",
      "properties": {
        "min": { "type": "number" },
        "median": { "type": "number" },
        "p95": { "type": "number" },
        "max": { "type": "number" }
      },
      "required": ["min", "median", "p95", "max"]
    },
    "budget_exceeded": { "type": "boolean" }
  },
  "required": ["timestamp", "device", "os_version", "build_configuration", "protocol", "extension_memory_mb", "budget_exceeded"]
}
```

---

## 4. Execution Script

To capture memory footprint during local testing on macOS:

```bash
# Run safe memory benchmark logger
./benchmarks/run_memory_benchmark.sh
```

