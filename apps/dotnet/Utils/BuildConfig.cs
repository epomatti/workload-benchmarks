namespace pets;
public class BuildConfig
{
  private readonly EnvironmentSettings _settings;

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
  }

  public EnvironmentSettings GetConfig()
  {
    return _settings;
  }
}