pnpm create astro@latest . --template minimal --no-install --no-git --skip-houston --yes
perl -0pi -e 's/defineConfig\(\{/defineConfig({\n  server: { allowedHosts: true },/' astro.config.mjs
must_contain allowedHosts astro.config.mjs
pnpm install
