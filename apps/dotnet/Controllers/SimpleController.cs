using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Benchmark.Simple;

// [IdentityBasicAuthentication]
[Authorize]
[ApiController]
[Route("/api/simple")]

public class SimpleController : ControllerBase
{
  private PersistenceContext _context;

  public SimpleController(PersistenceContext context)
  {
    _context = context;
  }

  [Route("parent")]
  [HttpPost]
  public async Task<ActionResult<SimpleParent>> Create(SimpleParent parent)
  {
    await _context.SimpleParents.AddAsync(parent);
    await _context.SaveChangesAsync();
    return CreatedAtAction(nameof(Create), new { id = parent.Id }, parent);
  }


  [HttpGet("/parent/{id}")]
  public async Task<ActionResult<SimpleParent?>> GetById(int id)
  {
    SimpleParent? parents = await _context.SimpleParents.FindAsync(id);
    if (parents == null)
    {
      return NotFound();
    }
    return Ok(parents);
  }

}