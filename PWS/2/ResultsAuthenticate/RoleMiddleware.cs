using Microsoft.AspNetCore.Http;

namespace ResultsAuthenticate;

public class RoleMiddleware
{
    private readonly RequestDelegate _next;

    public RoleMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        string path = context.Request.Path;

        string method = context.Request.Method;

        if (path.StartsWith("/api/Results/SignIn"))
        {
            await _next(context);
            return;
        }

        if (!context.User.Identity?.IsAuthenticated ?? true)
        {
            context.Response.StatusCode = 401;
            return;
        }

        string? role =
            context.User.FindFirst(
                System.Security.Claims.ClaimTypes.Role)?.Value;

        bool readerRequest =
            method == "GET";

        bool writerRequest =
            method == "POST" ||
            method == "PUT" ||
            method == "DELETE";

        if (readerRequest && role != "READER")
        {
            context.Response.StatusCode = 403;
            return;
        }

        if (writerRequest && role != "WRITER")
        {
            context.Response.StatusCode = 403;
            return;
        }

        await _next(context);
    }
}