# Elixir is not a homemade VM runtime, so mix runs in the official elixir image, here and in the VM.
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e MIX_HOME=/tmp/mix -e HEX_HOME=/tmp/hex -v "$PWD:/work" -w /work elixir:1.18 bash -euo pipefail -c '
  mix local.hex --force >/dev/null && mix local.rebar --force >/dev/null
  mix archive.install hex phx_new --force >/dev/null
  mix phx.new app --app app --module App --no-install --no-mailer --no-gettext --no-dashboard
  cd app && mix deps.get'
shopt -s dotglob && mv app/* . && rmdir app && shopt -u dotglob
rm -rf deps _build
# Dev: Postgres on the VM port, listen on 0.0.0.0:$PORT.
perl -0pi -e 's/hostname: "localhost"/hostname: "127.0.0.1",\n  port: 54329/; s/http: \[ip: \{127, 0, 0, 1\}, port: String.to_integer\(System.get_env\("PORT"\) \|\| "4000"\)\]/http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")]/' config/dev.exs
must_contain 'port: 54329' config/dev.exs
must_contain 'ip: {0, 0, 0, 0}' config/dev.exs
printf '/.mix/\n/.hex/\n' >>.gitignore
