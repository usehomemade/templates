pnpm dlx create-t3-app@latest app --CI --tailwind --drizzle --trpc --appRouter --dbProvider postgres --noGit --noInstall
shopt -s dotglob && mv app/* . && rmdir app && shopt -u dotglob
rm -f start-database.sh
# Next blocks dev assets and the HMR socket for other origins; the VM's URL is one.
insert_after "const config = {" '  allowedDevOrigins: ["*.onhomemade.com", "*.onhmmd.com"],' next.config.js
printf "allowBuilds:\n  esbuild: true\n" >>pnpm-workspace.yaml
pnpm add redis
pnpm install
