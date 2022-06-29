using Microsoft.AspNetCore.Mvc;
namespace pets;

[ApiController]
[Route("/api/pets")]

public class PetController : ControllerBase
{

  private readonly BuildConfig _config;

  public PetController(BuildConfig config)
  {
    _config = config;
  }

  [HttpGet]
  public IEnumerable<Pet> Get()
  {
    Console.WriteLine("hahaha");
    Console.WriteLine(_config.GetConfig().DB_SERVER);

    return null;
  }

}