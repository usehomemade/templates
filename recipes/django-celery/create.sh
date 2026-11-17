uv init --app --no-package --name app --vcs none --author-from none .
uv add django "psycopg[binary]" celery redis dj-database-url "watchdog[watchmedo]"
uv run django-admin startproject config .
uv run python manage.py startapp core
rm -f main.py
django_dev_settings config/settings.py
# Postgres from DATABASE_URL, Celery on Redis, the core app.
perl -0pi -e 's/DATABASES = \{.*?\n\}\n/DATABASES = {"default": dj_database_url.config(default="postgresql:\/\/postgres:postgres\@127.0.0.1:54329\/app")}\n/s; s/^import os$/import os\n\nimport dj_database_url/m; s/(INSTALLED_APPS = \[\n)/$1    "core",\n/' config/settings.py
must_contain dj_database_url.config config/settings.py
must_contain '"core",' config/settings.py
cat >>config/settings.py <<'PY'

CELERY_BROKER_URL = os.environ.get("CELERY_BROKER_URL", "redis://127.0.0.1:63799/0")
CELERY_RESULT_BACKEND = os.environ.get("CELERY_RESULT_BACKEND", "redis://127.0.0.1:63799/1")
PY
insert_after "from django.urls import path" "from core.views import home" config/urls.py
insert_after "urlpatterns = [" '    path("", home),' config/urls.py
uv lock
