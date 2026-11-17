# Laravel + MySQL

A Laravel app (`composer create-project laravel/laravel`) on MySQL. Regenerated every week by [usehomemade/templates](https://github.com/usehomemade/templates).

A homemade VM has no PHP runtime of its own, so `.homemade/config.json` builds a small PHP image (`.homemade/php.Dockerfile`: PHP 8.4, `pdo_mysql`, Composer) and runs `php artisan serve` in it next to MySQL in Docker. PHP reads your files on every request, so edits show on reload. `.env` holds dev values only (a fixed dev `APP_KEY`, the VM's MySQL).
