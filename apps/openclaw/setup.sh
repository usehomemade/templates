#!/usr/bin/env bash
# OpenClaw setup: build it, then configure the gateway for a VM: no login (the VM URL is
# owner-only), any origin, and the VM's proxies trusted.
# Run from /workspace/app (the upstream clone) as `bash .homemade/setup.sh`, in the app's install step.
set -euo pipefail

pnpm install --frozen-lockfile
pnpm build

node openclaw.mjs setup --baseline
node openclaw.mjs config set gateway.auth.mode none
node openclaw.mjs config set gateway.controlUi.allowedOrigins '["*"]' --strict-json
node openclaw.mjs config set gateway.trustedProxies '["127.0.0.1","::1","10.0.0.0/8","172.16.0.0/12"]' --strict-json
