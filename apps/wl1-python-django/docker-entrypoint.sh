#!/bin/sh
python manage.py migrate
# gunicorn wl1_python_django.wsgi
python manage.py runserver