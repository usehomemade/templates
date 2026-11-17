#!/usr/bin/env bash
set -euo pipefail
curl -fsS --max-time 20 http://127.0.0.1:3000/ | grep -q "Start a homemade VM" && echo "seed rows render"
pnpm exec supabase stop --no-backup >/dev/null 2>&1 || true
