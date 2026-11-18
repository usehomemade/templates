#!/usr/bin/env bash
# nanobot setup: let the dev web UI run behind a VM URL, then give the gateway a WebUI
# password and the link that signs you in with it.
# Run from /workspace/app (the upstream clone) as `bash .homemade/setup.sh`, in the app's install step.
set -euo pipefail
set -a; . /etc/homemade/env; set +a

# The VM URL of one of its ports: the port goes after the VM name in the host name.
port_url() { printf '%s' "${HOMEMADE_URL#https://}" | sed "s/-$HOMEMADE_VM_NAME-/-$HOMEMADE_VM_NAME-$1-/"; }

# Vite accepts any host, and its live-reload socket goes through the VM URL's port 443.
perl -0pi -e 's/strictPort: true,/strictPort: true,\n      allowedHosts: true,/; s/hmr: \{\n        host: "127.0.0.1",/hmr: {\n        clientPort: 443,\n        protocol: "wss",/' webui/vite.config.ts

# The gateway's WebSocket channel with a fresh bootstrap secret, the WebUI password.
secret=$(openssl rand -hex 16)
mkdir -p ~/.nanobot .homemade
jq -n --arg secret "$secret" --arg ws "wss://$(port_url 8765)" \
  '{channels:{websocket:{enabled:true,host:"127.0.0.1",port:8765,publicWsUrl:$ws,tokenIssueSecret:$secret}}}' >~/.nanobot/config.json
chmod 600 ~/.nanobot/config.json

# Shown on the VM page under the WebUI service.
echo "https://$(port_url 5173)/#/?bootstrapSecret=$secret" >.homemade/sign-in-link.txt
chmod 600 .homemade/sign-in-link.txt
