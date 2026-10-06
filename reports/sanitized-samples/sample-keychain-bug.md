# Sanitized Defect Sample: Transient Keychain Access Error Fallback

- **Defect ID**: `BUG-STR-001`
- **Title**: Background tunnel launch fails to read password credential when device locked (Keychain errSecItemNotFound)
- **Severity**: P1 - Critical
- **Priority**: High
- **Suspected Area**: Storage / ServerStore Keychain Access
- **Build / Commit**: `v1.0-beta.4 (commit: e9a2c3f)`
- **Test Environment**:
  - Device: Physical iPhone 14 Pro
  - OS Version: iOS 17.4
  - Network Type: Wi-Fi (Home Router)

---

## 1. Description
When `NEPacketTunnelProvider` attempts to start in the background while the physical device screen is locked, `SecItemCopyMatching` fails with error code `-34018` or `errSecItemNotFound`. If the server credential relies solely on Keychain, the connection aborts.

## 2. Preconditions
- Server configured with UUID credential in Keychain.
- Device locked with passcode for > 10 minutes.

## 3. Steps to Reproduce
1. Schedule a background shortcut or automated connect action.
2. Allow device to lock and enter standby mode.
3. Trigger connection initiation.

## 4. Expected Result
The tunnel manager accesses the credential via the protected App Group fallback container (`group.com.via.vpn/credentials/`) and successfully starts the tunnel.

## 5. Actual Result
`KeychainManager.readString(key:)` threw `KeychainError.itemNotFound`. The connection failed with `credentialsExpired`.

## 6. Reproducibility
- [x] 100% (Deterministic when device locked)

## 7. Sanitized Logs & Diagnostics
```
[2026-10-06T11:20:10Z] [Storage] [ERROR] Failed to read credential 'server_cred_REDACTED': itemNotFound
[2026-10-06T11:20:10Z] [VPN] [ERROR] State Transition: preparing -> failed(credentialsExpired)
```

## 8. Resolution / Mitigation
Implemented Dual-Persist strategy in `ServerStore.swift`: writes redundant atomic copy of credential into App Group `credentials/` subdirectory with atomic file permissions.

