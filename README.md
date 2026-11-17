# homemade templates

What homemade.dev puts in a new template project. Two kinds:

- **Starters** (one folder each): a ready app made by the stack's own create command, with its lockfile and a `.homemade/config.json`. A new VM copies the folder.
- **Apps** (`apps/<id>/app.json`): popular self-hosted apps we do not copy. The file holds only the upstream repo, which ref to track and our config. A new VM clones the upstream's latest release (or its branch when it has no releases) and runs it from that config.

## Starters

| Folder | Stack | Services | Dev server |
|---|---|---|---|
| `nextjs` | Next.js, pnpm | web | `pnpm dev` on 3000 |
| `vite-react` | Vite, React, pnpm | web | `pnpm dev` on 5173 |
| `astro` | Astro, pnpm | web | `pnpm dev` on 4321 |
| `django` | Django, uv | web | `runserver` on 8000 |
| `go-api` | Go, net/http | api | `go tool air` (rebuild on save) on 8080 |
| `bun-hono` | Bun, Hono | api | `bun run --hot` on 3000 |
| `nextjs-postgres` | T3: Next.js, tRPC, Drizzle | Postgres 17, Redis 8, web | `pnpm dev` on 3000 |
| `supabase` | Next.js, Supabase | Supabase CLI stack, Studio, web | `pnpm dev` on 3000 |
| `payload` | Payload CMS, Next.js | Postgres 17, web | `pnpm dev` on 3000 |
| `django-celery` | Django, Celery | Postgres 17, Redis 8, worker, web | `runserver` on 8000, worker restarts on save |
| `rails` | Rails, Sidekiq | Postgres 17, Redis 8, Sidekiq, web | `rails server` on 3000 |
| `laravel-mysql` | Laravel, PHP 8.4 | MySQL 8.4, web | `artisan serve` on 8000 |
| `phoenix` | Phoenix, LiveView | Postgres 17, web | `mix phx.server` on 4000 |
| `open-webui` | Open WebUI, Ollama | Ollama with `qwen2.5:0.5b`, web | released images (no dev mode) |

Every dev server listens on `0.0.0.0` and `$PORT` and accepts any host name, so it works behind a VM's URL. Databases run in Docker inside the VM and start empty: no data is committed. `.env` files hold dev-only values.

## Apps

Each app keeps its own license; homemade is not affiliated with any of them. See `apps/<id>/app.json` for the exact setup.

APPS_TABLE

## How they are made

`scripts/generate.sh <folder>` sources `recipes/<folder>/create.sh` in an empty directory (the official create command plus small patches), copies `recipes/<folder>/files/` over it and writes the folder. `scripts/smoke.sh <folder>` runs the folder's `.homemade/config.json` the way a VM does: warmup, install from the lockfile, every service with `$PORT`, then checks each URL answers (and runs `recipes/<folder>/smoke.sh` when there is one).

The [Regenerate templates](.github/workflows/regenerate.yml) workflow regenerates every starter each Monday, smoke-checks each one in its own job and commits only when all of them pass. Apps are never rebuilt: VMs clone them fresh. homemade pins a commit of this repo (`pnpm --filter @homemade/schemas sync:templates`), so a regeneration reaches new projects once homemade moves the pin.
