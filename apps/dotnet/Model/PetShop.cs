using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace pets;

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