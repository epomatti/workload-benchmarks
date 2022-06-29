using System.Net;
using Microsoft.AspNetCore.Mvc;
namespace pets;

[ApiController]
[Route("/api/pets")]
public class PetController : ControllerBase
{

  private readonly BuildConfig _config;
  private PersistenceContext _context;

  public PetController(BuildConfig config, PersistenceContext context)
  {
    _config = config;
    _context = context;
  }

  [HttpGet]
  public IEnumerable<Pet> GetAll()
  {
    return _context.Pets!;
  }

  [HttpGet("{id}")]
  public async Task<Pet?> GetById(int id)
  {
    return await _context.Pets.FindAsync(id);
  }

  [HttpPost]
  public async Task<Pet> Create(CreatePetRequest request)
  {
    Owner? owner = await _context.Owners.FindAsync(request.Owner);
    if (owner == null)
    {
      throw new HttpResponseException(HttpStatusCode.BadRequest);
    }
    Pet pet = new Pet(request.Name!, request.Age, request.Breed!, request.Type!);
    pet.OwnerId = request.Owner;
    await _context.Pets.AddAsync(pet);
    await _context.SaveChangesAsync();
    return pet;
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

