using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace ResultsAuthenticate;

public class AuthenticateMiddleware
{
    private readonly RequestDelegate _next;

    public AuthenticateMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(
        HttpContext context,
        Authenticate authenticate)
    {
        if (context.Request.Path
            .StartsWithSegments("/api/Results/SignIn"))
        {
            await _next(context);
            return;
        }

        string? authorization =
            context.Request.Headers.Authorization;

        if (string.IsNullOrWhiteSpace(authorization) ||
            !authorization.StartsWith("Bearer "))
        {
            context.Response.StatusCode = 401;
            return;
        }

        string token = authorization.Substring("Bearer ".Length);

        if (!authenticate.ValidateToken(
                token,
                out string? login,
                out string? role))
        {
            context.Response.StatusCode = 401;
            return;
        }

        var identity = new ClaimsIdentity(
            new[]
            {
                new Claim(ClaimTypes.Name, login!),
                new Claim(ClaimTypes.Role, role!)
            },
            "CustomJWT");

        context.User = new ClaimsPrincipal(identity);

        await _next(context);
    }
}