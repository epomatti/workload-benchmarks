using System.ComponentModel.DataAnnotations.Schema;
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
            @"Data Source=localhost; Initial Catalog=master; User Id=SA; Password=StrPass#456");

  // "Data Source=localhost; Initial Catalog=dotnet-6-crud-api; User Id=testUser; Password=testPass123"
}

public class Owner
{
  [DatabaseGenerated(DatabaseGeneratedOption.None)]
  public int Id { get; set; }
  public string? Name { get; set; }
  public DateTime Birthday { get; set; }

  public List<Pet> Pets { get; } = new();
}

public class Pet
{
  [DatabaseGenerated(DatabaseGeneratedOption.None)]
  public int Id { get; set; }
  public string? Name { get; set; }
  public int Age { get; set; }

  public string? Breed { get; set; }
  public string? Type { get; set; }
  public Owner? Owner { get; set; }
}