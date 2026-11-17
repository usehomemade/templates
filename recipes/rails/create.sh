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
# Dev and test databases on the VM's Postgres container (54329), as plain keys so every task
# (db:prepare also touches test) connects over TCP, never a local socket.
perl -0pi -e 's/(\n(development|test):\n  <<: \*default\n)/$1  host: 127.0.0.1\n  port: 54329\n  username: postgres\n  password: postgres\n/g' config/database.yml
must_contain 'port: 54329' config/database.yml
grep -qx '/vendor/bundle' .gitignore || printf '/vendor/bundle\n' >>.gitignore
