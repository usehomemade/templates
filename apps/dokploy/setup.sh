#!/usr/bin/env bash
# Dokploy setup: dependencies, its .env for this VM's URL, a Docker Swarm and Postgres, then the migrations.
# Run from /workspace/app (the upstream clone) as `bash .homemade/setup.sh`, in the app's install step.
set -euo pipefail
set -a; . /etc/homemade/env; set +a

# The VM URL of one of its ports: the port goes after the VM name in the host name.
port_url() { printf '%s' "${HOMEMADE_URL#https://}" | sed "s/-$HOMEMADE_VM_NAME-/-$HOMEMADE_VM_NAME-$1-/"; }

# Node 24 and node-gyp's headers (the download fails now and then, so it retries).
mise use node@24
npm i -g node-gyp
for _ in 1 2 3 4 5; do node-gyp install && break; sleep 5; done
pnpm install --frozen-lockfile || pnpm install --frozen-lockfile

if [ ! -f apps/dokploy/.env ]; then
  cp apps/dokploy/.env.example apps/dokploy/.env
  printf 'BETTER_AUTH_URL=%s\nBETTER_AUTH_SECRET=%s\n' "https://$(port_url 3000)" "$(openssl rand -hex 32)" >>apps/dokploy/.env
fi
# Next.js dev accepts requests from the VM URL's domain.
grep -q allowedDevOrigins apps/dokploy/next.config.mjs ||
  sed -i 's|reactStrictMode: true,|reactStrictMode: true,\n\tallowedDevOrigins: ["*.onhmmd.com", "*.onhomemade.com"],|' apps/dokploy/next.config.mjs

# Dokploy needs Swarm mode and its Postgres (a throwaway dev password).
docker swarm init --advertise-addr "$(hostname -I | cut -d' ' -f1)" >/dev/null 2>&1 || true
docker start dokploy-postgres >/dev/null 2>&1 ||
  docker run -d --restart unless-stopped --name dokploy-postgres -p 5432:5432 \
    -e POSTGRES_USER=dokploy -e POSTGRES_DB=dokploy -e POSTGRES_PASSWORD=amukds4wi9001583845717ad2 \
    -v dokploy-postgres:/var/lib/postgresql/data postgres:16 >/dev/null
until docker exec dokploy-postgres pg_isready -U dokploy -h 127.0.0.1 >/dev/null 2>&1; do sleep 1; done
sleep 3

pnpm --filter=dokploy run migration:run
pnpm run server:script
