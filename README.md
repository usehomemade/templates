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

Apps are not copied here. `apps/<id>/app.json` holds only our setup and which upstream ref to track. When a VM is created, it clones the app's latest release tag (or default branch) straight from GitHub, installs it and runs it in dev mode.

| App | Upstream | License | Tracks | Notes |
| --- | --- | --- | --- | --- |
| `openclaw` | [openclaw/openclaw](https://github.com/openclaw/openclaw) | MIT | latest release | Medium VM. First boot builds the gateway (about 9 min). Control UI runs on Vite. No login; the URL is owner-only. |
| `nanobot` | [HKUDS/nanobot](https://github.com/HKUDS/nanobot) | MIT | latest release | WebUI password and sign-in link in `~/nanobot-password.txt`. |
| `t3code` | [pingdotgg/t3code](https://github.com/pingdotgg/t3code) | MIT | latest release | Pairing link in `~/t3-pairing-link.txt`. |
| `opencode` | [anomalyco/opencode](https://github.com/anomalyco/opencode) | MIT | latest release | Web app on Vite, API on 4096. |
| `cloudcli` | [siteboon/claudecodeui](https://github.com/siteboon/claudecodeui) | AGPL-3.0-or-later | latest release | Web UI for Claude Code, Cursor CLI and Codex. |
| `coolify` | [coollabsio/coolify](https://github.com/coollabsio/coolify) | Apache-2.0 | latest release | Medium VM, upstream dev compose. Sign in as `test@example.com` / `password`. |
| `dokploy` | [Dokploy/dokploy](https://github.com/Dokploy/dokploy) | Apache-2.0 with extra terms | latest release | Dashboard works. Deploying apps does not: VMs have no vxlan, so Swarm overlay networks fail. |

## How they are made

`scripts/generate.sh <folder>` sources `recipes/<folder>/create.sh` in an empty directory (the official create command plus small patches), copies `recipes/<folder>/files/` over it and writes the folder. `scripts/smoke.sh <folder>` runs the folder's `.homemade/config.json` the way a VM does: warmup, install from the lockfile, every service with `$PORT`, then checks each URL answers (and runs `recipes/<folder>/smoke.sh` when there is one).

The [Regenerate templates](.github/workflows/regenerate.yml) workflow regenerates every starter each Monday, smoke-checks each one in its own job and commits only when all of them pass. Apps are never rebuilt: VMs clone them fresh. homemade pins a commit of this repo (`pnpm --filter @homemade/schemas sync:templates`), so a regeneration reaches new projects once homemade moves the pin.
