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
    SimpleParent? parent = await _context.SimpleParents.FindAsync(id);
    if (parent == null)
    {
      return NotFound();
    }
    return Ok(parent);
  }

  [Route("/api/simple/{parentId}/child1")]
  [HttpPost]
  public async Task<ActionResult<SimpleParent>> CreateSimpleChild1(long parentId, SimpleChild1 child)
  {
    SimpleParent? parent = await _context.SimpleParents.FindAsync(parentId);
    if (parent == null)
    {
      return NotFound();
    }

    // Random business rules
    if (child.String1 != "XXX")
    {
      child.InnerString1 = child.String1 + child.String2;
    };
    if (child.Number1 > -1)
    {
      child.Sum1 = child.Number1 + child.Number2;
    }
    var minDate = DateTime.MinValue;
    if (DateTime.Compare(child.DateTime1, minDate) > 0 && DateTime.Compare(child.DateTime2, minDate) > 0)
    {
      child.DateTimeControl1 = new DateTime();
    }
    // Random business rules

    await _context.SimpleChildren1.AddAsync(child);
    await _context.SaveChangesAsync();
    return CreatedAtAction(nameof(CreateSimpleChild1), new { id = child.Id }, child);
  }


}