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
sudo docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=StrPass#456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest
```

ℹ️ MSSQL 2022 is [not supported](https://github.com/microsoft/mssql-django/issues/149) at the time of writting.

```sh
python manage.py migrate
python manage.py runserver
```


## Reference Implementation

https://github.com/Azure-Samples/azure-sql-db-django