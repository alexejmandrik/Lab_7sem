
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace WS01_02.Controllers
{
    [ApiController]
    [Route("stack")]
    public class StackController : ControllerBase
    {
        private static int _result = 0;
        private const string CookieName = "STACK";

        private string ServerName =>
            Environment.GetEnvironmentVariable("SERVER_NAME") ?? "unknown";

        private List<int> GetStack()
        {
            if (!Request.Cookies.TryGetValue(CookieName, out var value))
                return new List<int>();

            try
            {
                return JsonSerializer.Deserialize<List<int>>(value)
                    ?? new List<int>();
            }
            catch
            {
                return new List<int>();
            }
        }

        private void SaveStack(List<int> stack)
        {
            Response.Cookies.Append(
                CookieName,
                JsonSerializer.Serialize(stack),
                new CookieOptions
                {
                    Path = "/",
                    HttpOnly = true,
                    SameSite = SameSiteMode.Lax
                });
        }

        private int GetValue(List<int> stack)
        {
            return _result + (stack.Count > 0 ? stack[0] : 0);
        }

        [HttpGet]
        public IActionResult Get()
        {
            var stack = GetStack();

            return Ok(new
            {
                result = GetValue(stack),
                name = ServerName
            });
        }

        [HttpPost]
        public IActionResult Post([FromBody] ResultModel model)
        {
            _result = model.RESULT;

            return Ok(new
            {
                result = _result,
                name = ServerName
            });
        }

        [HttpPut]
        public IActionResult Put([FromQuery] int ADD)
        {
            var stack = GetStack();
            stack.Insert(0, ADD);
            SaveStack(stack);

            return Ok(new
            {
                result = GetValue(stack),
                name = ServerName
            });
        }

        [HttpDelete]
        public IActionResult Delete()
        {
            var stack = GetStack();

            if (stack.Count <= 1)
            {
                SaveStack(new List<int>());

                return BadRequest(new
                {
                    error = "Стек пуст",
                    name = ServerName
                });
            }

            stack.RemoveAt(0);
            SaveStack(stack);

            return Ok(new
            {
                result = GetValue(stack),
                name = ServerName
            });
        }
    }

    public class ResultModel
    {
        public int RESULT { get; set; }
    }
}
