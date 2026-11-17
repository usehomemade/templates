#!/usr/bin/env bash
# The tiny model answers through Ollama.
set -euo pipefail
curl -fsS --max-time 20 http://127.0.0.1:11434/api/generate -d '{"model":"qwen2.5:0.5b","prompt":"Say hi","stream":false}' | jq -r .response | head -c 200; echo
