#!/usr/bin/env bash
# CloudCLI setup: build the native modules, make ripgrep available and add a Vite config that
# accepts any host, so the dev server works behind a VM URL.
# Run from /workspace/app (the upstream clone) as `bash .homemade/setup.sh`, in the app's install step.
set -euo pipefail

npm ci --ignore-scripts
npm rebuild bcrypt better-sqlite3 esbuild node-pty sharp

# ripgrep's own download, else the VM's rg.
if ! { npm rebuild @vscode/ripgrep >/dev/null 2>&1 && test -x node_modules/@vscode/ripgrep/bin/rg; }; then
  mkdir -p node_modules/@vscode/ripgrep/bin
  ln -sf "$(command -v rg)" node_modules/@vscode/ripgrep/bin/rg
fi

cat >vite.homemade.config.js <<'XEOF'
import { defineConfig, mergeConfig } from "vite"
import base from "./vite.config.js"

export default defineConfig(async (env) =>
  mergeConfig(await (typeof base === "function" ? base(env) : base), { server: { allowedHosts: true } }))
XEOF
