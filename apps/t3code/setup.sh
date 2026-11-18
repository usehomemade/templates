#!/usr/bin/env bash
# T3 Code setup: a pairing token for this VM and the link that signs you in with it.
# Run from /workspace/app (the upstream clone) as `bash .homemade/setup.sh`, in the app's install step.
set -euo pipefail
set -a; . /etc/homemade/env; set +a

# The VM URL of one of its ports: the port goes after the VM name in the host name.
port_url() { printf '%s' "${HOMEMADE_URL#https://}" | sed "s/-$HOMEMADE_VM_NAME-/-$HOMEMADE_VM_NAME-$1-/"; }

# The pairing token the T3 server accepts (T3CODE_DEV_AUTH_TOKEN); made once, kept across boots.
mkdir -p "$HOME/.t3-share" .homemade
[ -s "$HOME/.t3-share/token" ] || head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n' >"$HOME/.t3-share/token"

# Shown on the VM page under the T3 Code service.
echo "https://$(port_url 5733)/pair#token=$(cat "$HOME/.t3-share/token")" >.homemade/sign-in-link.txt
chmod 600 .homemade/sign-in-link.txt
