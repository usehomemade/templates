# homemade templates

The starter apps homemade.dev puts in a new template project. One folder per template:

| Folder | Stack | Install | Dev server |
|---|---|---|---|
| `nextjs` | Next.js, pnpm | `pnpm install --frozen-lockfile` | `pnpm dev` on 3000 |
| `vite-react` | Vite, React, pnpm | `pnpm install --frozen-lockfile` | `pnpm dev` on 5173 |
| `astro` | Astro, pnpm | `pnpm install --frozen-lockfile` | `pnpm dev` on 4321 |
| `django` | Django, uv | `uv sync --frozen` | `runserver` on 8000 |
| `go-api` | Go, net/http | `go mod download` | `go run .` on 8080 |
| `bun-hono` | Bun, Hono | `bun install --frozen-lockfile` | `bun run --hot` on 3000 |

Each folder is a normal app with its lockfile and a `.homemade/config.json`. Every dev server listens on `0.0.0.0` and `$PORT` (the port in the table when `$PORT` is unset) and accepts any host name, so it works behind a VM's URL.

## How they are made

`scripts/generate.sh <folder>` runs the official create command (`create-next-app`, `create vite`, `create astro`, `uv init` + `django-admin startproject`, `go mod init`, `bun create hono`), applies the small patches above and writes the lockfile. `scripts/smoke.sh <folder>` installs from the lockfile, builds, starts the dev server and checks that it answers.

The [Regenerate templates](.github/workflows/regenerate.yml) workflow does both for every folder each Monday and commits only when all of them pass. homemade pins a commit of this repo, so a regeneration reaches new projects once homemade moves the pin.
