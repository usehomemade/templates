#!/usr/bin/env bash
# OpenCode setup: a Vite config for the web app that forwards API calls to the OpenCode server
# (port 4096) and sets import.meta.env.DEV to false, so it works behind a VM URL.
# Run from /workspace/app (the upstream clone) as `bash .homemade/setup.sh`, in the app's install step.
set -euo pipefail

cat >packages/app/vite.homemade.config.ts <<'XEOF'
import { mergeConfig } from "vite"
import base from "./vite.config"

const api = "^/(agent|api|auth|command|config|doc|event|experimental|file|find|formatter|global|instance|log|lsp|mcp|path|permission|project|provider|pty|question|session|skill|sync|tui|vcs)(/|$)"

export default mergeConfig(base, {
  server: {
    proxy: {
      [api]: {
        target: "http://127.0.0.1:4096",
        ws: true,
        changeOrigin: true,
        bypass: (req: any) => (req.headers.accept?.includes("text/html") ? req.url : undefined),
      },
    },
  },
  define: { "import.meta.env.DEV": "false" },
})
XEOF
