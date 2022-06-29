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
  public async Task<ActionResult<Owner?>> GetById(int id)
  {
    Owner? owner = await _context.Owners.FindAsync(id);
    if (owner == null)
    {
      return NotFound();
    }
    return Ok(owner);
  }

  [HttpPost]
  public async Task<ActionResult<Owner>> Create(Owner owner)
  {
    await _context.Owners.AddAsync(owner);
    await _context.SaveChangesAsync();
    return CreatedAtAction(nameof(Create), new { id = owner.Id }, owner);
  }

}