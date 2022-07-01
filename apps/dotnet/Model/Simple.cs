using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace Benchmark.Simple;

public class SimpleParent
{
  [Key]
  [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
  public long Id { get; set; }
  public string? String1 { get; set; }
  public string? String2 { get; set; }
  public string? String3 { get; set; }
  [JsonIgnore]
  public string? InnerString1 { get; set; }
  public int Number1 { get; set; }
  public int Number2 { get; set; }
  public int Number3 { get; set; }
  [JsonIgnore]
  public long Sum1 { get; set; }
  public DateTime DateTime1 { get; set; }
  public DateTime DateTime2 { get; set; }
  public DateTime DateTime3 { get; set; }
  [JsonIgnore]
  public DateTime DateTimeControl1 { get; set; }
  public List<SimpleChild1> Children1 { get; } = new();
  public List<SimpleChild2> Children2 { get; } = new();
}

public class SimpleChild1
{
  [Key]
  [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
  public int Id { get; set; }

  public string? String1 { get; set; }
  public string? String2 { get; set; }
  public int Number1 { get; set; }
  public int Number2 { get; set; }
  public DateTime DateTime1 { get; set; }
  public DateTime DateTime2 { get; set; }

  [JsonIgnore]
  public SimpleParent? Parent { get; set; }
}

public class SimpleChild2
{
  [Key]
  [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
  public int Id { get; set; }

  public string? String1 { get; set; }
  public string? String2 { get; set; }
  public int Number1 { get; set; }
  public int Number2 { get; set; }
  public DateTime DateTime1 { get; set; }
  public DateTime DateTime2 { get; set; }

  [JsonIgnore]
  public SimpleParent? Parent { get; set; }
}
