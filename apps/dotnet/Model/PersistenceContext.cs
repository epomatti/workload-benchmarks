using Benchmark.Simple;
using Microsoft.EntityFrameworkCore;
using pets;

public class PersistenceContext : DbContext
{

  private BuildConfig _config;

  public DbSet<Owner> Owners => Set<Owner>();
  public DbSet<Pet> Pets => Set<Pet>();
  public DbSet<SimpleParent> SimpleParents => Set<SimpleParent>();
  public DbSet<SimpleChild1> SimpleChildren1 => Set<SimpleChild1>();
  public DbSet<SimpleChild2> SimpleChildren2 => Set<SimpleChild2>();

  public PersistenceContext(BuildConfig config)
  {
    _config = config;
  }

  protected override void OnConfiguring(DbContextOptionsBuilder options)
      => options.UseSqlServer(
            @_config.GetDatabaseConnectionString());
}
