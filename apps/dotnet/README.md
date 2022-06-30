

docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=StrPass#456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest


dotnet tool install --global dotnet-ef
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet ef migrations add InitialCreate
dotnet ef database update



```sh
az group create -n 'rg-benchmark-dev' -l 'brazilsouth'
az monitor log-analytics workspace create -g 'rg-benchmark-dev' -n 'log-benchmark-dev'
workspaceId=$(az monitor log-analytics workspace show -g 'rg-benchmark-dev' -n 'log-benchmark-dev' --query id -o tsv)
az monitor app-insights component create --app 'appi-benchmark-dotnet-dev' -l 'brazilsouth' -g 'rg-benchmark-dev' --workspace $workspaceId
az monitor app-insights component show --app 'appi-benchmark-dotnet-dev' -g 'rg-benchmark-dev' --query connectionString -o tsv
```
