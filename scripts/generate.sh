#!/usr/bin/env bash
# Regenerates one template folder from its create command.
#   scripts/generate.sh <id>     (ids: see scripts/templates.txt)
# The app is created in a temp dir, patched so it runs inside a homemade VM
# (dev server on 0.0.0.0 and $PORT, any Host header allowed), given its lockfile
# and a .homemade/config.json, then swapped in for ./<id>.
set -euo pipefail

id="${1:?usage: generate.sh <id>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
app="$work/$id"
mkdir -p "$app"
cd "$app"

# Inserts $2 on the line after the first line matching $1 in file $3; fails when nothing matched.
insert_after() {
  local pattern="$1" text="$2" file="$3"
  grep -q -- "$pattern" "$file" || { echo "generate: '$pattern' not found in $file" >&2; exit 1; }
  awk -v pat="$pattern" -v txt="$text" '{ print } !done && index($0, pat) { print txt; done = 1 }' "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
}

# config.json: install command, service name, service cmd, port
write_config() {
  mkdir -p .homemade
  cat >.homemade/config.json <<EOF
{
  "\$schema": "https://homemade.dev/schemas/latest/config.json",
  "install": ["$1"],
  "services": {
    "$2": { "cmd": "$3", "port": $4, "url": true }
  }
}
EOF
}

case "$id" in
  nextjs)
    pnpm dlx create-next-app@latest . --ts --eslint --tailwind --app --src-dir --use-pnpm --yes --skip-install --disable-git
    # Next blocks dev assets (HMR) for other origins; the VM's URL is one.
    insert_after "const nextConfig: NextConfig = {" '  allowedDevOrigins: ["*.onhomemade.com", "*.onhmmd.com"],' next.config.ts
    pnpm install
    write_config "pnpm install --frozen-lockfile" web 'pnpm dev --hostname 0.0.0.0 --port ${PORT:-3000}' 3000
    name="Next.js"; run="pnpm dev"
    ;;
  vite-react)
    pnpm create vite@latest . --template react-ts --no-interactive
    # Vite refuses unknown Host headers; the VM's URL is one.
    insert_after "export default defineConfig({" "  server: { allowedHosts: true }," vite.config.ts
    pnpm install
    write_config "pnpm install --frozen-lockfile" web 'pnpm dev --host 0.0.0.0 --port ${PORT:-5173}' 5173
    name="Vite + React"; run="pnpm dev"
    ;;
  astro)
    pnpm create astro@latest . --template minimal --no-install --no-git --skip-houston --yes
    perl -0pi -e 's/defineConfig\(\{/defineConfig({\n  server: { allowedHosts: true },/' astro.config.mjs
    grep -q allowedHosts astro.config.mjs || { echo "generate: astro.config.mjs not patched" >&2; exit 1; }
    pnpm install
    write_config "pnpm install --frozen-lockfile" web 'pnpm dev --host 0.0.0.0 --port ${PORT:-4321}' 4321
    name="Astro"; run="pnpm dev"
    ;;
  django)
    uv init --app --no-package --name app --vcs none --author-from none . && uv add django && uv run django-admin startproject config .
    rm -f main.py
    # Any host: the VM's URL changes per VM. Forms posted from it pass CSRF.
    sed -i.bak 's/^ALLOWED_HOSTS = \[\]$/ALLOWED_HOSTS = ["*"]/' config/settings.py && rm config/settings.py.bak
    grep -q 'ALLOWED_HOSTS = \["\*"\]' config/settings.py || { echo "generate: ALLOWED_HOSTS not patched" >&2; exit 1; }
    # A fixed dev key (startproject writes a new random one each run); real deploys set DJANGO_SECRET_KEY.
    perl -0pi -e 's/^SECRET_KEY = .*$/SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY", "django-insecure-homemade-template-dev-only")/m; s/^from pathlib import Path$/import os\nfrom pathlib import Path/m' config/settings.py
    grep -q 'DJANGO_SECRET_KEY' config/settings.py || { echo "generate: SECRET_KEY not patched" >&2; exit 1; }
    printf '\nCSRF_TRUSTED_ORIGINS = ["https://*.onhomemade.com", "https://*.onhmmd.com"]\n' >>config/settings.py
    uv lock
    write_config "uv sync --frozen" web 'uv run manage.py runserver 0.0.0.0:${PORT:-8000}' 8000
    name="Django"; run="uv run manage.py runserver"
    ;;
  go-api)
    go mod init app
    cat >main.go <<'EOF'
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Hello from Go")
	})
	log.Printf("listening on 0.0.0.0:%s", port)
	log.Fatal(http.ListenAndServe("0.0.0.0:"+port, nil))
}
EOF
    printf '/app\n' >.gitignore
    write_config "go mod download" api "go run ." 8080
    name="Go API"; run="go run ."
    ;;
  bun-hono)
    bun create hono@latest . --template bun --pm bun --install
    write_config "bun install --frozen-lockfile" api 'PORT=${PORT:-3000} bun run --hot src/index.ts' 3000
    name="Bun + Hono"; run="bun run dev"
    ;;
  *)
    echo "generate: unknown template '$id'" >&2
    exit 1
    ;;
esac

cat >README.md <<EOF
# $name

The $name starter homemade.dev puts in a new template project. Regenerated every week from the official create command by [usehomemade/templates](https://github.com/usehomemade/templates). Run it with \`$run\`; \`.homemade/config.json\` has the install command and the dev server homemade starts.
EOF

rm -rf "${root:?}/$id"
mkdir -p "$root/$id"
# Copy without what .gitignore drops (node_modules, .venv, builds).
git -C "$app" init -q && git -C "$app" add -A
git -C "$app" ls-files -z | (cd "$app" && xargs -0 tar -cf -) | tar -xf - -C "$root/$id"
echo "generate: $id done ($(git -C "$app" ls-files | wc -l | tr -d ' ') files)"
