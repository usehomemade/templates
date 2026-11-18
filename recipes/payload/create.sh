pnpm dlx create-payload-app@latest -n app -t blank --db postgres --db-connection-string "postgresql://postgres:postgres@127.0.0.1:54329/app" --no-deps --no-agent --use-pnpm
shopt -s dotglob && mv app/* . && rmdir app && shopt -u dotglob
rm -rf .git
# A fixed dev secret (the CLI writes a random one each run).
perl -pi -e 's/^PAYLOAD_SECRET=.*$/PAYLOAD_SECRET=homemade-template-dev-only-secret/' .env
must_contain 'PAYLOAD_SECRET=homemade-template-dev-only-secret' .env
printf "allowBuilds:\n  esbuild: true\n  sharp: true\n  unrs-resolver: true\n" >pnpm-workspace.yaml
# The template pins pnpm <= 11 and newer Node in "engines"; a VM runs whatever versions its host ships.
jq 'del(.engines)' package.json >package.json.tmp && mv package.json.tmp package.json
pnpm install
