pnpm create vite@latest . --template react-ts --no-interactive
# Vite refuses unknown Host headers; the VM's URL is one.
insert_after "export default defineConfig({" "  server: { allowedHosts: true }," vite.config.ts
pnpm install
