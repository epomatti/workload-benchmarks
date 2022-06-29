

docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=StrPass#456" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest


dotnet tool install --global dotnet-ef
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet ef migrations add InitialCreate
dotnet ef database update