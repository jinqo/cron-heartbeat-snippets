#!/usr/bin/env bash
# Usage: PING=https://example.invalid/ping/ID ./wrapper.sh /usr/local/bin/backup.sh [args...]
# Sends /start, runs the command, then pings success or /fail with the exit code.
set -u
: "${PING:?set PING to your heartbeat URL}"
ping() { curl -fsS -m 10 --retry 3 -o /dev/null "$1" || echo "heartbeat ping failed: $1" >&2; }
ping "$PING/start"
if "$@"; then
  ping "$PING"
else
  rc=$?
  ping "$PING/fail"
  exit "$rc"
fi
