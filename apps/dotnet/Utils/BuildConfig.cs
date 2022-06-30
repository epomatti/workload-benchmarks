namespace pets;
public class BuildConfig
{
  private readonly EnvironmentSettings _settings;
  private readonly string _connectionString;

  public BuildConfig()
  {
    var environmentName = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");

    var builder = new ConfigurationBuilder()
        .AddJsonFile("appsettings.json")
        .AddJsonFile($"appsettings.{environmentName}.json", true)
        .AddEnvironmentVariables();

    IConfigurationRoot configRoot = builder.Build();

    _settings = new EnvironmentSettings();
    ConfigurationBinder.Bind(configRoot, _settings);

    // Connection String
    _connectionString = $"Data Source={_settings.DB_SERVER}; Initial Catalog={_settings.DB_NAME}; User Id={_settings.DB_USER}; Password={_settings.DB_PASSWORD}";
  }

  public EnvironmentSettings GetConfig()
  {
    return _settings;
  }

  public string GetDatabaseConnectionString()
  {
    return _connectionString;
  }
}