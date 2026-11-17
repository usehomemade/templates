# Rails + Postgres + Redis + Sidekiq

A Rails app (`rails new --database=postgresql`) with Sidekiq on Redis. The home page reads Postgres and queues a Sidekiq job on each visit. Regenerated every week by [usehomemade/templates](https://github.com/usehomemade/templates).

A homemade VM has no Ruby runtime of its own, so `.homemade/config.json` runs Rails and Sidekiq in the official `ruby` image (gems in `vendor/bundle`), next to Postgres and Redis in Docker. `rails server` runs in development mode and picks up edits on reload.
