using Microsoft.AspNetCore.Mvc;

namespace Benchmark.Simple;

[ApiController]
public class SimpleController : ControllerBase
{
  private PersistenceContext _context;

  public SimpleController(PersistenceContext context)
  {
    _context = context;
  }

  [Route("/api/simple")]
  [HttpPost]
  public async Task<ActionResult<SimpleParent>> CreateSimpleParent(SimpleParent parent)
  {
    // Random business rules
    if (parent.String1 != "XXX")
    {
      parent.InnerString1 = parent.String1 + parent.String2 + parent.String3;
    };
    if (parent.Number1 > -1)
    {
      parent.Sum1 = parent.Number1 + parent.Number2 + parent.Number3;
    }
    var minDate = DateTime.MinValue;
    if (DateTime.Compare(parent.DateTime1, minDate) > 0 && DateTime.Compare(parent.DateTime2, minDate) > 0 && DateTime.Compare(parent.DateTime3, minDate) > 0)
    {
      parent.DateTimeControl1 = new DateTime();
    }
    // Random business rules

    await _context.SimpleParents.AddAsync(parent);
    await _context.SaveChangesAsync();
    return CreatedAtAction(nameof(CreateSimpleParent), new { id = parent.Id }, parent);
  }

  [Route("/api/simple/{id}")]
  [HttpGet]
  public async Task<ActionResult<SimpleParent?>> GetById(long id)
  {
    SimpleParent? parents = await _context.SimpleParents.FindAsync(id);
    if (parents == null)
    {
      return NotFound();
    }
    return Ok(parents);
  }

  [Route("/api/simple/{id}/child1")]
  [HttpPost]
  public async Task<ActionResult<SimpleParent>> CreateSimpleChild1(SimpleParent parent)
  {
    await _context.SimpleParents.AddAsync(parent);
    await _context.SaveChangesAsync();
    return CreatedAtAction(nameof(CreateSimpleChild1), new { id = parent.Id }, parent);
  }


}