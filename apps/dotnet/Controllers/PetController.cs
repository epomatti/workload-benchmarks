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
  public async Task<Pet> GetById(Pet pet)
  {
    _context.Pets.Add(pet);
    await _context.SaveChangesAsync();
    return pet;
  }

}

