using System.Net;
using Microsoft.AspNetCore.Mvc;
namespace pets;

[ApiController]
[Route("/api/pets")]
public class PetController : ControllerBase
{


  private PersistenceContext _context;

  public PetController(PersistenceContext context)
  {
    _context = context;
  }

  [HttpGet]
  public IEnumerable<Pet> GetAll()
  {
    return _context.Pets!;
  }

  [HttpGet("{id}")]
  public async Task<ActionResult<Pet?>> GetById(int id)
  {

    Pet? pet = await _context.Pets.FindAsync(id);
    if (pet == null)
    {
      return NotFound();
    }
    return Ok(pet);
  }

  [HttpPost]
  public async Task<ActionResult<Pet>> Create(CreatePetRequest request)
  {
    Owner? owner = await _context.Owners.FindAsync(request.Owner);
    if (owner == null)
    {
      return new BadRequestResult();
    }
    Pet pet = new Pet(request.Name!, request.Age, request.Breed!, request.Type!);
    pet.Owner = owner;
    await _context.Pets.AddAsync(pet);
    await _context.SaveChangesAsync();
    return CreatedAtAction(nameof(Create), new { id = pet.Id }, pet);
  }

  public class CreatePetRequest
  {
    public string? Name { get; set; }
    public int Age { get; set; }
    public string? Type { get; set; }
    public string? Breed { get; set; }
    public int Owner { get; set; }
  }

}

