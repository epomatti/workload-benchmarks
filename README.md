# Workload Benchmarks

Project to load test various languages with dummy data to help determine sizing requirements on Azure.

## Load Testing

Set the target environment:

```sh
# For local testing
export K6_HOST="http://localhost:5187"

# For testing in the cloud
export K6_HOST="https://app-benchmark-dotnet999.azurewebsites.net"
```

Run the test - change the loading parameters as per requirement:

> ⚠️ To avoid public connection interference it is recommended to do load testing with origin restrictions from your source IP, or use the jumpbox VM that is provisioned as part of the Terraform scripts.

```ps1
k6 run --vus 200 --duration 120s pets.js
```

## .NET Core

### Local Development

Start the database:

```sh
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=StrPass#456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest
```

Start the server:

```
dotnet restore
dotnet run
```

To test with Application Insights:

```sh
az group create -n 'rg-benchmark-dev' -l 'brazilsouth'
az monitor log-analytics workspace create -g 'rg-benchmark-dev' -n 'log-benchmark-dev'
workspaceId=$(az monitor log-analytics workspace show -g 'rg-benchmark-dev' -n 'log-benchmark-dev' --query id -o tsv)
az monitor app-insights component create --app 'appi-benchmark-dotnet-dev' -l 'brazilsouth' -g 'rg-benchmark-dev' --workspace $workspaceId
az monitor app-insights component show --app 'appi-benchmark-dotnet-dev' -g 'rg-benchmark-dev' --query connectionString -o tsv

export APPLICATIONINSIGHTS_CONNECTION_STRING='<....>'
```
