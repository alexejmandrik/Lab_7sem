
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace WS01_01.Controllers;

[ApiController]
[Route("stack")]
public class StackController : ControllerBase
{
    private string ServerName =>
    Environment.GetEnvironmentVariable("SERVER_NAME") ?? "unknown";
    private const string StackKey = "STACK";

    // Общий RESULT для всех сессий одного экземпляра сервера.
    private static int _result = 0;
    private static readonly object ResultLock = new();

    // Стек текущей сессии. Последний элемент списка — вершина.
    private List<int> GetStack()
    {
        string? json = HttpContext.Session.GetString(StackKey);

        if (string.IsNullOrEmpty(json))
        {
            return new List<int>();
        }

        return JsonSerializer.Deserialize<List<int>>(json)
               ?? new List<int>();
    }

    private void SaveStack(List<int> stack)
    {
        HttpContext.Session.SetString(
            StackKey,
            JsonSerializer.Serialize(stack));
    }

    private int GetResult()
    {
        lock (ResultLock)
        {
            return _result;
        }
    }

    // GET /stack
    [HttpGet]
    public IActionResult Get()
    {
        var stack = GetStack();
        int result = GetResult();

        if (stack.Count > 0)
        {
            result += stack[^1];
        }

        return Ok(new
        {
            RESULT = result,
            NAME = ServerName
        });
    }

    // POST /stack
    [HttpPost]
    public IActionResult Post([FromBody] ResultRequest request)
    {
        lock (ResultLock)
        {
            _result = request.RESULT;

            return Ok(new { RESULT = _result });
        }
    }

    // PUT /stack?ADD=5
    [HttpPut]
    public IActionResult Put([FromQuery(Name = "ADD")] int add)
    {
        List<int> stack = GetStack();

        stack.Add(add);
        SaveStack(stack);

        return Ok(new { RESULT = GetResult() + add });
    }

    // DELETE /stack
    [HttpDelete]
    public IActionResult Delete()
    {
        List<int> stack = GetStack();

        if (stack.Count == 0)
        {
            return BadRequest(new { error = "Стек пуст" });
        }

        int value = stack[^1];
        stack.RemoveAt(stack.Count - 1);

        SaveStack(stack);

        return Ok(new { RESULT = GetResult() + value });
    }
}

public class ResultRequest
{
    public int RESULT { get; set; }
}
