# Django + Postgres + Celery + Redis

A Django project (`config`) with a `core` app, Postgres through `DATABASE_URL`, and a Celery worker on Redis. The home page queries Postgres and runs a Celery task. Regenerated every week by [usehomemade/templates](https://github.com/usehomemade/templates).

In a homemade VM, `.homemade/config.json` starts Postgres and Redis in Docker, migrates, and runs `runserver` (reloads on save) and the worker (restarts on save through `watchmedo`). The connection defaults in `config/settings.py` point at those two services.
