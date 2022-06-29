using Microsoft.AspNetCore.Mvc;
namespace pets;

[ApiController]
[Route("/api/pets")]

public class PetController : ControllerBase
{

  private readonly BuildConfig _config;
  private PetContext _context;

  public PetController(BuildConfig config, PetContext context)
  {
    _config = config;
    _context = context;
  }

  [HttpGet]
  public IEnumerable<Pet> Get()
  {
    return _context.Pets!;
  }

}