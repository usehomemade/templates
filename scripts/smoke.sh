#!/usr/bin/env bash
# Smoke-checks one template folder the way a homemade VM runs it: the install
# command from .homemade/config.json, a production build where the stack has
# one, then the dev server on $PORT until it answers below 500.
#   scripts/smoke.sh <id>
set -euo pipefail

id="${1:?usage: smoke.sh <id>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/$id"
cd "$dir"

config=".homemade/config.json"
install="$(jq -r '.install[]' "$config")"
cmd="$(jq -r '.services[].cmd' "$config")"
port=$((20000 + RANDOM % 20000))

echo "smoke $id: install"
bash -euo pipefail -c "$install"

echo "smoke $id: build"
case "$id" in
  nextjs | vite-react | astro) pnpm build ;;
  django) uv run manage.py check ;;
  go-api) go build -o /tmp/smoke-go-api . ;;
  bun-hono) bun build src/index.ts --target=bun --outdir /tmp/smoke-bun-hono >/dev/null ;;
esac

echo "smoke $id: start on $port"
log="$(mktemp)"
if command -v setsid >/dev/null; then run=(setsid bash); else run=(bash); fi
PORT="$port" "${run[@]}" -c "$cmd" >"$log" 2>&1 &
pid=$!
cleanup() { kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true; }
trap cleanup EXIT

for _ in $(seq 1 90); do
  code="$(curl -s -o /dev/null -w '%{http_code}' -H "Host: smoke.onhmmd.com" "http://127.0.0.1:$port/" || true)"
  if [ "$code" != "000" ] && [ "$code" -lt 400 ]; then
    echo "smoke $id: ok (HTTP $code)"
    exit 0
  fi
  sleep 1
done
echo "smoke $id: no answer below 400 on $port (last $code)" >&2
tail -n 40 "$log" >&2
exit 1
