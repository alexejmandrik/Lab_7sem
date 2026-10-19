using Microsoft.AspNetCore.Mvc;
using ResultsAuthenticate;

namespace REST01.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ResultsController : ControllerBase
{
    private readonly ResultsCollection.Results _results;
    private readonly Authenticate _authenticate;

    public ResultsController(
        ResultsCollection.Results results,
        Authenticate authenticate)
    {
        _results = results;
        _authenticate = authenticate;
    }

    // GET /api/Results
    // Требуется роль READER
    [HttpGet]
    public IActionResult GetAll()
    {
        var results = _results.GetAll();

        if (results.Count == 0)
            return NoContent();

        return Ok(results);
    }

    // GET /api/Results/{k}
    // Требуется роль READER
    [HttpGet("{k:int}")]
    public IActionResult Get(int k)
    {
        var result = _results.Get(k);

        if (result == null)
            return NotFound();

        return Ok(result);
    }

    // POST /api/Results
    // Требуется роль WRITER
    [HttpPost]
    public IActionResult Post([FromBody] ResultRequest request)
    {
        if (request == null ||
            string.IsNullOrWhiteSpace(request.Value))
        {
            return BadRequest();
        }

        var result = _results.Add(request.Value);

        return CreatedAtAction(
            nameof(Get),
            new { k = result.Id },
            result);
    }

    // PUT /api/Results/{k}
    // Требуется роль WRITER
    [HttpPut("{k:int}")]
    public IActionResult Put(
        int k,
        [FromBody] ResultRequest request)
    {
        if (request == null ||
            string.IsNullOrWhiteSpace(request.Value))
        {
            return BadRequest();
        }

        var result = _results.Update(k, request.Value);

        if (result == null)
            return NotFound();

        return Ok(result);
    }

    // DELETE /api/Results/{k}
    // Требуется роль WRITER
    [HttpDelete("{k:int}")]
    public IActionResult Delete(int k)
    {
        var result = _results.Delete(k);

        if (result == null)
            return NotFound();

        return Ok(result);
    }

    // POST /api/Results/SignIn
    [HttpPost("SignIn")]
    public IActionResult SignIn(
        [FromBody] LoginRequest request)
    {
        if (request == null ||
            string.IsNullOrWhiteSpace(request.Login) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest();
        }

        var token = _authenticate.SignIn(
            request.Login,
            request.Password);

        if (token == null)
            return NotFound();

        return Ok(new
        {
            token
        });
    }
}

public class ResultRequest
{
    public string Value { get; set; } = "";
}