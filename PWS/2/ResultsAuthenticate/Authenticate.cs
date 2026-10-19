using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Identity;

namespace ResultsAuthenticate;

public class LoginRequest
{
    public string Login { get; set; } = "";

    public string Password { get; set; } = "";
}

public class Authenticate
{
    private readonly PasswordHasher<User> _passwordHasher;

    private readonly List<User> _users;

    public const string SecretKey =
        "REST01_SECRET_KEY_123456789_REST01_SECRET_KEY";

    public Authenticate()
    {
        _passwordHasher = new PasswordHasher<User>();

        var reader = new User
        {
            Login = "reader",
            Role = "READER"
        };

        reader.PasswordHash =
            _passwordHasher.HashPassword(reader, "1234");

        var writer = new User
        {
            Login = "writer",
            Role = "WRITER"
        };

        writer.PasswordHash =
            _passwordHasher.HashPassword(writer, "1234");

        _users = new List<User>
        {
            reader,
            writer
        };
    }

    public string? SignIn(string login, string password)
    {
        var user = _users.FirstOrDefault(x =>
            x.Login.Equals(login, StringComparison.OrdinalIgnoreCase));

        if (user == null)
            return null;

        var result = _passwordHasher.VerifyHashedPassword(
            user,
            user.PasswordHash,
            password);

        if (result == PasswordVerificationResult.Failed)
            return null;

        return CreateToken(user);
    }

    private string CreateToken(User user)
    {
        var header = Base64UrlEncode(
            "{\"alg\":\"HS256\",\"typ\":\"JWT\"}");

        var payload = Base64UrlEncode(
            $"{{\"sub\":\"{user.Login}\",\"role\":\"{user.Role}\",\"exp\":{DateTimeOffset.UtcNow.AddHours(1).ToUnixTimeSeconds()}}}");

        var data = $"{header}.{payload}";

        using var hmac = new HMACSHA256(
            Encoding.UTF8.GetBytes(SecretKey));

        var signature = hmac.ComputeHash(
            Encoding.UTF8.GetBytes(data));

        return $"{data}.{Base64UrlEncode(signature)}";
    }

    public bool ValidateToken(
        string token,
        out string? login,
        out string? role)
    {
        login = null;
        role = null;

        try
        {
            var parts = token.Split('.');

            if (parts.Length != 3)
                return false;

            var data = $"{parts[0]}.{parts[1]}";

            using var hmac = new HMACSHA256(
                Encoding.UTF8.GetBytes(SecretKey));

            var signature = hmac.ComputeHash(
                Encoding.UTF8.GetBytes(data));

            var expectedSignature =
                Base64UrlEncode(signature);

            if (!CryptographicOperations.FixedTimeEquals(
                    Encoding.UTF8.GetBytes(parts[2]),
                    Encoding.UTF8.GetBytes(expectedSignature)))
            {
                return false;
            }

            var payloadJson = Encoding.UTF8.GetString(
                Base64UrlDecode(parts[1]));

            using var document =
                System.Text.Json.JsonDocument.Parse(payloadJson);

            var root = document.RootElement;

            login = root.GetProperty("sub").GetString();

            role = root.GetProperty("role").GetString();

            long exp = root.GetProperty("exp").GetInt64();

            if (DateTimeOffset.UtcNow.ToUnixTimeSeconds() >= exp)
                return false;

            return true;
        }
        catch
        {
            return false;
        }
    }

    private static string Base64UrlEncode(string text)
    {
        return Base64UrlEncode(
            Encoding.UTF8.GetBytes(text));
    }

    private static string Base64UrlEncode(byte[] data)
    {
        return Convert.ToBase64String(data)
            .Replace("+", "-")
            .Replace("/", "_")
            .TrimEnd('=');
    }

    private static byte[] Base64UrlDecode(string text)
    {
        string padded = text
            .Replace("-", "+")
            .Replace("_", "/");

        switch (padded.Length % 4)
        {
            case 2:
                padded += "==";
                break;

            case 3:
                padded += "=";
                break;
        }

        return Convert.FromBase64String(padded);
    }

    private class User
    {
        public string Login { get; set; } = "";

        public string PasswordHash { get; set; } = "";

        public string Role { get; set; } = "";
    }
}