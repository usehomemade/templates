pnpm dlx create-next-app@latest . --ts --eslint --tailwind --app --src-dir --use-pnpm --yes --skip-install --disable-git
# Next blocks dev assets and the HMR socket for other origins; the VM's URL is one.
insert_after "const nextConfig: NextConfig = {" '  allowedDevOrigins: ["*.onhomemade.com", "*.onhmmd.com"],' next.config.ts
pnpm install
