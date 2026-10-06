#!/usr/bin/env bash
# ==============================================================================
# Script: check_dns_leak.sh
# Purpose: Non-destructive verification of local DNS resolver configuration.
# ==============================================================================
set -euo pipefail

echo "=================================================="
echo "Via Quality Engineering - DNS Configuration Audit"
echo "=================================================="

echo "[*] Inspecting macOS SystemConfiguration DNS resolvers..."
if command -v scutil >/dev/null 2>&1; then
    RESOLVERS=$(scutil --dns 2>/dev/null | grep -E "nameserver\[[0-9]+\]" | head -n 5 || true)
    if [ -n "${RESOLVERS}" ]; then
        echo "[+] Configured System Resolvers:"
        echo "${RESOLVERS}"
    else
        echo "[*] No system DNS nameservers returned by scutil."
    fi
else
    echo "[*] scutil not available on this platform."
fi

echo "[*] Checking connectivity to configured DNS endpoint (if online)..."
if ping -c 1 -t 2 1.1.1.1 >/dev/null 2>&1; then
    echo "[+] Direct ping to 1.1.1.1 successful."
else
    echo "[*] Direct internet ping unavailable or offline in current environment."
fi

echo "[+] DNS Configuration Audit completed safely."

