using Microsoft.EntityFrameworkCore;
using pets;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddSingleton<BuildConfig>();
builder.Services.AddDbContext<PersistenceContext>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Application Insights Telemetry
builder.Services.AddApplicationInsightsTelemetry();
// Health Check
builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapHealthChecks("/healthz");

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
  app.UseSwagger();
  app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapControllers();

using (var scope = app.Services.CreateScope())
{
  var services = scope.ServiceProvider;
  var context = services.GetRequiredService<PersistenceContext>();
  if (context.Database.GetPendingMigrations().Any())
  {
    context.Database.Migrate();
  }
}

app.Run();
