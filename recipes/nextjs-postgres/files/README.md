# Next.js + Postgres + Redis (T3)

A [create-t3-app](https://create.t3.gg) starter (Next.js, tRPC, Drizzle, Tailwind) on Postgres, with Redis wired in (`/api/visits` counts in Redis). Regenerated every week by [usehomemade/templates](https://github.com/usehomemade/templates).

In a homemade VM, `.homemade/config.json` starts Postgres and Redis in Docker, pushes the Drizzle schema, then runs `pnpm dev` with hot reload. `.env` holds the dev connection strings for those two; nothing in it is a secret.
