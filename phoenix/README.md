# Phoenix + Postgres

A Phoenix app (`mix phx.new`) on Postgres, with LiveView and live reload. Regenerated every week by [usehomemade/templates](https://github.com/usehomemade/templates).

A homemade VM has no Elixir runtime of its own, so `.homemade/config.json` runs mix in the official `elixir` image (Hex, deps and builds stay in the project folder) next to Postgres in Docker. `mix phx.server` runs in dev mode: save a template or a module and the page reloads.
