using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using pets;

public class PersistenceContext : DbContext
{

  private BuildConfig _config;

  public DbSet<Owner> Owners => Set<Owner>();
  public DbSet<Pet> Pets => Set<Pet>();

  public PersistenceContext(BuildConfig config)
  {
    _config = config;
  }

  protected override void OnConfiguring(DbContextOptionsBuilder options)
      => options.UseSqlServer(
            @"Data Source=localhost; Initial Catalog=master; User Id=SA; Password=StrPass#456");

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
  public string Name { get; set; }
  public int Age { get; set; }
  public string Breed { get; set; }
  public string Type { get; set; }
  public Owner? Owner { get; set; }

  [ForeignKey("Owner")]
  public int OwnerFK { get; set; }

  public Pet(string name, int age, string breed, string type)
  {
    Name = name;
    Age = age;
    Breed = breed;
    Type = type;
  }

}