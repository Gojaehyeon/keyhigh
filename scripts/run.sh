#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

./scripts/build.sh

APP=".build/KeyHigh.app"
BIN="${APP}/Contents/MacOS/KeyHigh"
LOG_DIR="${HOME}/Library/Logs/KeyHigh"
LOG="${LOG_DIR}/keyhigh.log"

mkdir -p "${LOG_DIR}"

# kill any previous instance so position/permission reload cleanly
pkill -x KeyHigh 2>/dev/null || true
sleep 0.3

# Launching the binary directly from the shell (rather than `open`) makes
# KeyHigh inherit the shell's Input Monitoring grant. With ad-hoc signing
# every rebuild produces a fresh code hash, so a permission granted to a
# previous build does not transfer — using the shell's inherited grant
# sidesteps the re-prompt loop during development.
echo "==> launching ${BIN}"
echo "    log: ${LOG}"
nohup "${BIN}" > "${LOG}" 2>&1 &
disown

sleep 0.6
if pgrep -x KeyHigh > /dev/null; then
    echo "==> KeyHigh started (pid $(pgrep -x KeyHigh))"
else
    echo "ERROR: KeyHigh did not start. Tail of log:" >&2
    tail -n 20 "${LOG}" >&2 || true
    exit 1
fi
