#!/bin/sh

# Liveness probe script for Trident CSI controller
# This script checks:
# 1. Trident version is accessible (existing behavior)
# 2. All backends are online

set -e

TRIDENT_SERVER="${TRIDENT_SERVER:-127.0.0.1:8000}"

# Check version (existing behavior)
echo "Checking Trident version..."
if ! tridentctl -s "$TRIDENT_SERVER" version > /dev/null 2>&1; then
    echo "ERROR: Failed to get Trident version"
    exit 1
fi
echo "Trident version check passed"

# Check backend status
echo "Checking backend status..."
BACKEND_STATUS=$(tridentctl -s "$TRIDENT_SERVER" get backend -o yaml 2>&1)

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to get backend status"
    exit 1
fi

# Parse YAML and check for offline backends
# Look for "state:" field with "offline" value
OFFLINE_BACKENDS=$(echo "$BACKEND_STATUS" | grep -E "^\s*state:\s*(offline|failed)" || true)

if [ -n "$OFFLINE_BACKENDS" ]; then
    echo "ERROR: Found offline backend(s):"
    echo "$OFFLINE_BACKENDS"
    exit 1
fi

echo "All backends are online"
exit 0
