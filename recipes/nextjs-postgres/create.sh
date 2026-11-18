pnpm dlx create-t3-app@latest app --CI --tailwind --drizzle --trpc --appRouter --dbProvider postgres --noGit --noInstall
shopt -s dotglob && mv app/* . && rmdir app && shopt -u dotglob
rm -f start-database.sh
printf "allowBuilds:\n  esbuild: true\n" >>pnpm-workspace.yaml
pnpm add redis
pnpm install
