#!/usr/bin/env bash
# Forward device localhost:8000 → Mac localhost:8000 (physical phone or emulator).
set -euo pipefail

ADB_BIN="${ADB:-adb}"
if ! command -v "$ADB_BIN" >/dev/null 2>&1; then
  for candidate in \
    "$HOME/Library/Android/sdk/platform-tools/adb" \
    "$HOME/Android/Sdk/platform-tools/adb"; do
    if [[ -x "$candidate" ]]; then
      ADB_BIN="$candidate"
      break
    fi
  done
fi

if ! command -v "$ADB_BIN" >/dev/null 2>&1; then
  echo "⚠ adb not found — Android local dev needs: adb reverse tcp:8000 tcp:8000"
  exit 0
fi

# Prefer USB phone when emulator + device are both connected.
ADB=( "$ADB_BIN" )
device_count=$("$ADB_BIN" devices | awk 'NR>1 && $2=="device" {c++} END {print c+0}')
if [[ "$device_count" -eq 0 ]]; then
  echo "⚠ No Android device connected — plug in USB and enable USB debugging."
  exit 0
fi
if [[ "$device_count" -gt 1 ]]; then
  ADB=( "$ADB_BIN" -d" )
  echo "Multiple devices — using USB phone (-d)."
fi

"${ADB[@]}" reverse tcp:8000 tcp:8000
echo "✓ adb reverse tcp:8000 tcp:8000 (phone 127.0.0.1:8000 → Mac Laravel)"
