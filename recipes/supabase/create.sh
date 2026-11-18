pnpm dlx create-next-app@latest . --ts --eslint --tailwind --app --src-dir --use-pnpm --yes --skip-install --disable-git
perl -0pi -e 's/^allowBuilds:\n/allowBuilds:\n  supabase: true\n/m' pnpm-workspace.yaml
must_contain "supabase: true" pnpm-workspace.yaml
pnpm add @supabase/supabase-js
pnpm add -D supabase
pnpm exec supabase init --force
perl -pi -e 's/^project_id = .*$/project_id = "app"/' supabase/config.toml
must_contain 'project_id = "app"' supabase/config.toml
