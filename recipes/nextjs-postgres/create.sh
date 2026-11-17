pnpm dlx create-t3-app@latest app --CI --tailwind --drizzle --trpc --appRouter --dbProvider postgres --noGit --noInstall
shopt -s dotglob && mv app/* . && rmdir app && shopt -u dotglob
rm -f start-database.sh
# Next blocks dev assets and the HMR socket for other origins; the VM's URL is one.
# create-t3-app writes `const config = {};` on one line.
perl -0pi -e 's/const config = \{\s*\};/const config = {\n  allowedDevOrigins: ["*.onhomemade.com", "*.onhmmd.com"],\n};/' next.config.js
must_contain 'allowedDevOrigins' next.config.js
printf "allowBuilds:\n  esbuild: true\n" >>pnpm-workspace.yaml
pnpm add redis
pnpm install
