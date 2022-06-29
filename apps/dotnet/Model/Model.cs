using Microsoft.EntityFrameworkCore;
using pets;

public class PetContext : DbContext
{

  BuildConfig _config;

  public DbSet<Owner>? Owners { get; set; }
  public DbSet<Pet>? Pets { get; set; }

  public PetContext(BuildConfig config)
  {
    _config = config;
  }

  protected override void OnConfiguring(DbContextOptionsBuilder options)
      => options.UseSqlServer(
            @"Server=(localdb)\mssqllocaldb;Database=Blogging;Trusted_Connection=True");
}

public class Owner
{
  public int Id { get; set; }
  public string? Name { get; set; }
  public DateTime Birthday { get; set; }

  public List<Pet> Pets { get; } = new();
}

public class Pet
{
  public int Id { get; set; }
  public string? Name { get; set; }
  public int Age { get; set; }

  public string? Breed { get; set; }
  public string? Type { get; set; }
  public Owner? Owner { get; set; }
}