using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
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
  [Key]
  [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
  public int Id { get; set; }
  public string? Name { get; set; }
  public DateTime Birthday { get; set; }

  public List<Pet> Pets { get; } = new();
}

public class Pet
{
  [Key]
  [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
  public int Id { get; set; }
  public string Name { get; set; }
  public int Age { get; set; }
  public string Breed { get; set; }
  public string Type { get; set; }

  [JsonIgnore]
  public Owner? Owner { get; set; }

  public Pet(string name, int age, string breed, string type)
  {
    Name = name;
    Age = age;
    Breed = breed;
    Type = type;
  }

}