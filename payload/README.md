# Payload CMS + Postgres

Payload's blank template (`create-payload-app -t blank`) on Postgres: the admin panel at `/admin` and the Next.js frontend in one app. Regenerated every week by [usehomemade/templates](https://github.com/usehomemade/templates).

In a homemade VM, `.homemade/config.json` starts Postgres in Docker and runs `pnpm dev` with hot reload; Payload creates the tables on first start. `.env` holds dev values only (the VM's Postgres and a fixed dev `PAYLOAD_SECRET`).
