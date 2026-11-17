uv init --app --no-package --name app --vcs none --author-from none . && uv add django && uv run django-admin startproject config .
rm -f main.py
django_dev_settings config/settings.py
uv lock
