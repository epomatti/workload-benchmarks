using Microsoft.AspNetCore.Mvc;
namespace pets;

[ApiController]
[Route("/api/owners")]

public class OwnerController : ControllerBase
{

  private readonly BuildConfig _config;
  private PersistenceContext _context;

  public OwnerController(BuildConfig config, PersistenceContext context)
  {
    _config = config;
    _context = context;
  }

  [HttpGet]
  public IEnumerable<Owner> GetAll()
  {
    return _context.Owners!;
  }

  [HttpGet("{id}")]
  public async Task<Owner?> GetById(int id)
  {
    return await _context.Owners.FindAsync(id);
  }

  [HttpPost]
  public async Task<Owner> GetById(Owner owner)
  {
    _context.Owners.Add(owner);
    await _context.SaveChangesAsync();
    return owner;
  }

}