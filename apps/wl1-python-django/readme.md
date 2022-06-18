# Workload 1: Pythong with Django

```sh
cp .config/dev.env .env
```

```sh
poetry install --dev
poetry shell
```

```sh
python manage.py migrate
python manage.py runserver
```