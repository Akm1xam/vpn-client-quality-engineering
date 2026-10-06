# Defect Report Template

- **Defect ID**: `BUG-[AREA]-[NUMBER]` (e.g. `BUG-NET-004`)
- **Title**: `[Short descriptive title summarizing the failure]`
- **Severity**: `[P0 - Blocker | P1 - Critical | P2 - Major | P3 - Minor]`
- **Priority**: `[Immediate | High | Normal | Low]`
- **Suspected Area**: `[VPN State Machine | XrayBridge | Parser | NetworkExtension | UI]`
- **Build / Commit**: `[Git commit SHA or Build Version]`
- **Test Environment**:
  - Device: `[e.g. iPhone 15 Pro | iOS Simulator iPhone 18 Pro]`
  - OS Version: `[e.g. iOS 18.0 | macOS 15.0]`
  - Network Type: `[Wi-Fi 6 | 5G Cellular | Dual-Stack]`

---

## 1. Description
A clear and concise description of the defect.

## 2. Preconditions
- Server configured: `[Protocol type, e.g. VLESS Reality]`
- Network state: `[Online / Offline / Flapping]`

## 3. Steps to Reproduce
1. Step 1...
2. Step 2...
3. Step 3...

## 4. Expected Result
What should have happened according to specifications.

## 5. Actual Result
What actually occurred (including exact error messages or crash codes).

## 6. Reproducibility
- [ ] 100% (Deterministic)
- [ ] Intermittent (~50%)
- [ ] Observed once

## 7. Sanitized Logs & Diagnostics
```
[Paste sanitized logs here. Confirm NO passwords, private keys, or real IPs are present.]
```

## 8. Regression Status
- Is this a regression from a previous build? `[Yes / No / Unknown]`
- If yes, last known good build: `[Commit SHA]`

