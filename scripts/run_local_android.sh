#!/usr/bin/env bash
# Local flavor on Android: adb reverse + flutter run.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

"$(dirname "$0")/adb_reverse.sh"

FLUTTER="${FLUTTER:-fvm flutter}"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER="flutter"
fi

exec $FLUTTER run --flavor local -t lib/main_local.dart "$@"
