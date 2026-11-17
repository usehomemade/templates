from django.db import connection
from django.http import HttpResponse

from .tasks import add


def home(request):
    # One round trip through each part of the stack: Postgres, then Redis and a Celery worker.
    with connection.cursor() as cursor:
        cursor.execute("select version()")
        (pg,) = cursor.fetchone()
    result = add.delay(2, 3).get(timeout=10)
    return HttpResponse(
        "<h1>Django + Postgres + Celery + Redis</h1>"
        f"<p>Postgres: {pg.split(' on ')[0]}</p>"
        f"<p>Celery worker says 2 + 3 = {result}</p>"
        "<p>Edit core/views.py and reload: runserver picks it up.</p>"
    )
