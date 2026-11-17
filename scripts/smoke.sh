#!/usr/bin/env bash
# Smoke-checks one template folder the way a homemade VM runs it, from its
# .homemade/config.json: every `warmup:` command, every `install:` command,
# then every service with PORT set to its port. Passes when each service with
# `url: true` answers below 400 (with a foreign Host header, as behind a VM URL).
# recipes/<id>/smoke.sh, when present, runs last with the services still up.
#   scripts/smoke.sh <id>
set -euo pipefail

id="${1:?usage: smoke.sh <id>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root/$id"
config=".homemade/config.json"
timeout_s="$(cat "$root/recipes/$id/smoke-timeout" 2>/dev/null || echo 180)"
logs="$(mktemp -d)"
pids=()

cleanup() {
  for pid in "${pids[@]}"; do kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true; done
  # Containers a service started (docker run --name ...) go with the check.
  docker ps -aq --filter "label=homemade.template" 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1 || true
  for name in $(jq -r '.services[].cmd' "$config" | grep -o -- '--name [A-Za-z0-9_.-]*' | awk '{print $2}' | sort -u); do
    docker rm -f "$name" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT

run_list() {
  jq -r --arg k "$1" '.[$k] // [] | .[]' "$config" | while IFS= read -r command; do
    echo "smoke $id: $1: $command"
    bash -euo pipefail -c "$command"
  done
}
run_list warmup
run_list install

if command -v setsid >/dev/null; then spawn=(setsid bash); else spawn=(bash); fi
while IFS=$'\t' read -r name port cmd; do
  echo "smoke $id: start $name on ${port:-no port}"
  if [ -n "$port" ]; then
    PORT="$port" "${spawn[@]}" -c "$cmd" >"$logs/$name.log" 2>&1 &
  else
    "${spawn[@]}" -c "$cmd" >"$logs/$name.log" 2>&1 &
  fi
  pids+=($!)
done < <(jq -r '.services | to_entries[] | select(.value.cmd != null) | [.key, (.value.port // "" | tostring), .value.cmd] | @tsv' "$config")

deadline=$((SECONDS + timeout_s))
for port in $(jq -r '.services[] | select(.url == true) | .port' "$config"); do
  path="$(jq -r --argjson p "$port" '.services[] | select(.port == $p) | .healthcheck.path // "/"' "$config")"
  code=000
  while [ "$SECONDS" -lt "$deadline" ]; do
    code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 30 -H "Host: smoke.onhmmd.com" "http://127.0.0.1:$port$path" || true)"
    if [ "$code" != 000 ] && [ "$code" -lt 400 ]; then break; fi
    sleep 2
  done
  if [ "$code" = 000 ] || [ "$code" -ge 400 ]; then
    echo "smoke $id: :$port$path did not answer below 400 in ${timeout_s}s (last $code)" >&2
    for f in "$logs"/*.log; do echo "--- $f" >&2; tail -n 40 "$f" >&2; done
    exit 1
  fi
  echo "smoke $id: :$port$path ok (HTTP $code)"
done

if [ -x "$root/recipes/$id/smoke.sh" ]; then
  echo "smoke $id: extra checks"
  "$root/recipes/$id/smoke.sh"
fi
echo "smoke $id: passed"
