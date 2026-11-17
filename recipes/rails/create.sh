# Ruby is not a homemade VM runtime, so Rails runs in the official ruby image, here and in the VM.
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e GEM_HOME=/tmp/gems -e PATH=/tmp/gems/bin:/usr/local/bin:/usr/bin:/bin \
  -v "$PWD:/app" -w /app ruby:3.4 bash -euo pipefail -c '
    gem install rails --no-document >/dev/null
    rails new . --database=postgresql --skip-git --skip-docker --skip-kamal --skip-thruster --skip-ci --skip-test --skip-system-test --skip-bundle --skip-jbuilder
    bundle add sidekiq --skip-install
    bundle lock'
# Any Host in development (the VM URL); Postgres and Redis from env with the VM defaults.
insert_after "Rails.application.configure do" '  config.hosts.clear' config/environments/development.rb
insert_after "Rails.application.routes.draw do" '  root "pages#home"' config/routes.rb
perl -0pi -e 's/(development:\n  <<: \*default\n)/$1  url: <%= ENV.fetch("DATABASE_URL", "postgresql:\/\/postgres:postgres\@127.0.0.1:54329\/app") %>\n/' config/database.yml
must_contain 'DATABASE_URL' config/database.yml
grep -qx '/vendor/bundle' .gitignore || printf '/vendor/bundle\n' >>.gitignore
