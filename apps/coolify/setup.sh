#!/usr/bin/env bash
# Coolify setup: its dev .env for this VM's URLs, Vite pointed at the VM URL, then the images.
# Run from /workspace/app (the upstream clone) as `bash .homemade/setup.sh`, in the app's install step.
set -euo pipefail
set -a; . /etc/homemade/env; set +a

# The VM URL of one of its ports: the port goes after the VM name in the host name.
port_url() { printf '%s' "${HOMEMADE_URL#https://}" | sed "s/-$HOMEMADE_VM_NAME-/-$HOMEMADE_VM_NAME-$1-/"; }

sudo mkdir -p /data/coolify/image-scans
sudo chown "$USER": /data/coolify/image-scans

if [ ! -f .env ]; then
  cp .env.development.example .env
  sed -i "s|^APP_KEY=.*|APP_KEY=base64:$(openssl rand -base64 32)|; s|^APP_URL=.*|APP_URL=https://$(port_url 8000)|; s|^VITE_HOST=.*|VITE_HOST=$(port_url 5173)|" .env
  printf 'VITE_PROTOCOL=https\nPUSHER_PORT=443\nPUSHER_SCHEME=https\n' >>.env
fi
# The Vite client reaches the VM URL through port 443.
sed -i 's|clientPort: vitePort|clientPort: 443|; s|origin: `${viteProtocol}://${viteHost}:${vitePort}`|origin: `${viteProtocol}://${viteHost}`|' vite.config.js

compose=(docker compose -p coolify -f docker-compose.yml -f docker-compose.dev.yml)
"${compose[@]}" build
"${compose[@]}" pull --ignore-buildable
