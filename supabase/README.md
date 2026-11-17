# Next.js + Supabase

A Next.js app on a full local Supabase stack (Postgres, Auth, REST, Realtime, Storage, Studio) run by the Supabase CLI in Docker. The home page reads the `todos` table from `supabase/migrations` and `supabase/seed.sql`. Regenerated every week by [usehomemade/templates](https://github.com/usehomemade/templates).

In a homemade VM, `.homemade/config.json` runs `supabase start`, passes its URL and anon key to `pnpm dev` (hot reload), and gives Studio its own URL. Supabase needs more memory than the smallest VM, so the config asks for `small`.
