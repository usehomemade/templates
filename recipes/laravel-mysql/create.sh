# PHP is not a homemade VM runtime, so Composer and Laravel run in Docker, here and in the VM.
docker run --rm --user "$(id -u):$(id -g)" -e COMPOSER_HOME=/tmp/composer -v "$PWD:/app" -w /app composer:2 \
  create-project laravel/laravel . --no-interaction --prefer-dist --ignore-platform-reqs --no-scripts
cp .env.example .env
# MySQL in the VM, a fixed dev APP_KEY (key:generate would write a new one every week).
perl -0pi -e 's/^APP_KEY=.*$/APP_KEY=base64:aG9tZW1hZGUtdGVtcGxhdGUtZGV2LW9ubHkta2V5ISE=/m; s/^DB_CONNECTION=.*$/DB_CONNECTION=mysql/m; s/^# ?DB_HOST=.*$/DB_HOST=127.0.0.1/m; s/^# ?DB_PORT=.*$/DB_PORT=33069/m; s/^# ?DB_DATABASE=.*$/DB_DATABASE=app/m; s/^# ?DB_USERNAME=.*$/DB_USERNAME=root/m; s/^# ?DB_PASSWORD=.*$/DB_PASSWORD=root/m' .env
must_contain 'DB_PORT=33069' .env
must_contain 'DB_CONNECTION=mysql' .env
rm -rf vendor
