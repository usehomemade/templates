#!/usr/bin/env bash
# Redis answers through the app, twice, and counts up.
set -euo pipefail
a=$(curl -fsS http://127.0.0.1:3000/api/visits | jq .visits); b=$(curl -fsS http://127.0.0.1:3000/api/visits | jq .visits)
[ "$b" -gt "$a" ] && echo "redis counter $a -> $b"
