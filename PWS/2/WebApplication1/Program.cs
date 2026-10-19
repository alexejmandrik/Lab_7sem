using ResultsAuthenticate;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// Библиотека ResultsCollection
builder.Services.AddTransient<ResultsCollection.Results>();

// Библиотека ResultsAuthenticate
builder.Services.AddScoped<Authenticate>();

var app = builder.Build();

// Аутентификация
app.UseMiddleware<AuthenticateMiddleware>();

// Проверка ролей
app.UseMiddleware<RoleMiddleware>();

app.MapControllers();

app.Run();