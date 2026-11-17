#!/usr/bin/env bash
# Regenerates one template folder from its recipe.
#   scripts/generate.sh <id>     (ids: scripts/templates.txt)
# recipes/<id>/create.sh runs the official create command in an empty temp dir (with the
# helpers below), recipes/<id>/files/ is copied over the result (.homemade/config.json,
# README, small patches), and the folder replaces ./<id>. Only files git would track are kept.
set -euo pipefail

id="${1:?usage: generate.sh <id>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
recipe="$root/recipes/$id"
[ -f "$recipe/create.sh" ] || { echo "generate: no recipe for '$id'" >&2; exit 1; }
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
app="$work/$id"
mkdir -p "$app"
cd "$app"

# Inserts $2 on the line after the first line containing $1 in file $3; fails when nothing matched.
insert_after() {
  local pattern="$1" text="$2" file="$3"
  grep -qF -- "$pattern" "$file" || { echo "generate: '$pattern' not found in $file" >&2; exit 1; }
  awk -v pat="$pattern" -v txt="$text" '{ print } !done && index($0, pat) { print txt; done = 1 }' "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
}
must_contain() { grep -qF -- "$1" "$2" || { echo "generate: '$1' missing in $2" >&2; exit 1; }; }

# Django dev settings that work behind a VM URL: any host, CSRF for the workload domains,
# a fixed dev key (startproject writes a random one each run; real deploys set DJANGO_SECRET_KEY).
django_dev_settings() {
  local f="$1"
  perl -0pi -e 's/^ALLOWED_HOSTS = \[\]$/ALLOWED_HOSTS = ["*"]/m; s/^SECRET_KEY = .*$/SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY", "django-insecure-homemade-template-dev-only")/m; s/^from pathlib import Path$/import os\nfrom pathlib import Path/m' "$f"
  must_contain 'ALLOWED_HOSTS = ["*"]' "$f"
  must_contain DJANGO_SECRET_KEY "$f"
  printf '\nCSRF_TRUSTED_ORIGINS = ["https://*.onhomemade.com", "https://*.onhmmd.com"]\n' >>"$f"
}

# shellcheck source=/dev/null
. "$recipe/create.sh"
cp -R "$recipe/files/." "$app/"

rm -rf "${root:?}/$id"
mkdir -p "$root/$id"
git -C "$app" init -q && git -C "$app" add -A && git -C "$app" add -f .env 2>/dev/null || true
git -C "$app" ls-files -z | (cd "$app" && xargs -0 tar -cf -) | tar -xf - -C "$root/$id"
echo "generate: $id done ($(git -C "$app" ls-files | wc -l | tr -d ' ') files)"
