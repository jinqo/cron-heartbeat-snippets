#!/usr/bin/env bash
set -euo pipefail
PING=https://example.invalid/ping/ID
borg create --stats "::{hostname}-{now}" /data
borg prune --keep-daily 7 --keep-weekly 4
curl -fsS -m 10 --retry 3 -o /dev/null "$PING"
