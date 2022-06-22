# Workload 1: Pythong with Django

## Local Development

Requirements:
- Linux Build Tools
- Pyenv (recommended)
- Poetry
- MSSQL ODBC
- Docker

```sh
cp .config/dev.env .env
```

```sh
poetry install
poetry shell

# If you're on WSL2 and install is hanging, disable IPv6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
```

First install the [ODBC Driver](https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server).

```sh
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=StrPass#456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest
```

ℹ️ MSSQL 2022 is [not supported](https://github.com/microsoft/mssql-django/issues/149) at the time of writting.

```sh
az extension add --name application-insights
az monitor app-insights component show --app 'appi-benchmark' -g 'rg-benchmark' --query 'connectionString' -o tsv
```

```sh
python manage.py migrate
python manage.py runserver
```

## K6

```sh
k6 run --vus 100 --duration 30s k6.js
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

### Docker with Network


```sh
docker network create django-network

docker run --rm --net django-network --name django-mssql -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=StrPass#456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest

sudo docker run --net django-network --rm -it --name django-app \
  -e "DB_NAME=master" \
  -e "DB_SERVER=django-mssql" \
  -e "DB_PORT=1433" \
  -e "DB_USER=SA" \
  -e "DB_PASSWORD=StrPass#456" \
  -e "DEBUG=True" \
  -p 8000:8000 django-app-image
```




## Reference Implementation

https://github.com/Azure-Samples/azure-sql-db-django
