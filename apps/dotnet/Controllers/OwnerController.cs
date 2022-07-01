using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace pets;

[ApiController]
[Route("/api/owners")]

public class OwnerController : ControllerBase
{

  private PersistenceContext _context;

  public OwnerController(PersistenceContext context)
  {
    _context = context;
  }

  [HttpGet]
  public IEnumerable<Owner> GetAll()
  {
    var owners = _context.Owners
                        .Include(o => o.Pets)
                        .ToList();
    return owners;
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