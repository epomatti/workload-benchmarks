# Workload 1: Pythong with Django

```sh
cp .config/dev.env .env
```

```sh
poetry install --dev
poetry shell
```

First install the [ODBC Driver](https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server).

```sh
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=StrPass#456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest
```

ℹ️ MSSQL 2022 is [not supported](https://github.com/microsoft/mssql-django/issues/149) at the time of writting.

```sh
python manage.py migrate
python manage.py runserver
```

## Docker

```sh
docker build -t django-app-image .

docker run -e "DB_NAME=master" \
  -e "DB_SERVER=localhost" \
  -e "DB_PORT=1433" \
  -e "DB_USER=SA" \
  -e "DB_PASSWORD=StrPass#456" \
  -p 8000:8000 django-app-image
```

docker run --rm -it --name django-app django-app-image

## Reference Implementation

https://github.com/Azure-Samples/azure-sql-db-django
