
using Grpc.Core;
using Grpc.Net.Client;
using CalculatorGrpc;

AppContext.SetSwitch(
    "System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport",
    true
);

using var channel = GrpcChannel.ForAddress("http://localhost:5000");

var client = new Calculator.CalculatorClient(channel);

Console.WriteLine("=== gRPC КАЛЬКУЛЯТОР ===");

Console.Write("Введите первое число X: ");
double x = double.Parse(Console.ReadLine()!);

Console.Write("Введите второе число Y: ");
double y = double.Parse(Console.ReadLine()!);

var request = new CalcRequest
{
    X = x,
    Y = y
};

Console.WriteLine("\n--- Результаты операций ---");

try
{
    var result = await client.SUMAsync(request);
    Console.WriteLine($"SUM = {result.Result}");
}
catch (RpcException ex)
{
    Console.WriteLine($"Ошибка SUM: {ex.Status.Detail}");
}

try
{
    var result = await client.SUBAsync(request);
    Console.WriteLine($"SUB = {result.Result}");
}
catch (RpcException ex)
{
    Console.WriteLine($"Ошибка SUB: {ex.Status.Detail}");
}

try
{
    var result = await client.MULAsync(request);
    Console.WriteLine($"MUL = {result.Result}");
}
catch (RpcException ex)
{
    Console.WriteLine($"Ошибка MUL: {ex.Status.Detail}");
}

try
{
    var result = await client.DIVAsync(request);
    Console.WriteLine($"DIV = {result.Result}");
}
catch (RpcException ex)
{
    Console.WriteLine($"Ошибка DIV: {ex.Status.Detail}");
}

Console.Write("\nВведите число для вычисления факториала: ");
int number = int.Parse(Console.ReadLine()!);

try
{
    var result = await client.FACTAsync(new FactRequest
    {
        X = number
    });

    Console.WriteLine($"FACT({number}) = {result.Result}");
}
catch (RpcException ex)
{
    Console.WriteLine($"Ошибка FACT: {ex.Status.Detail}");
}

Console.WriteLine("\nНажмите Enter для завершения...");
Console.ReadLine();
