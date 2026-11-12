
using CalculatorGrpc;
using Grpc.Core;
using System.Net.NetworkInformation;

namespace gRPCServer01.Services;

public class CalculatorService : Calculator.CalculatorBase
{
    public override Task<DoubleReply> SUM(
        CalcRequest request, ServerCallContext context)
    {
        return Task.FromResult(new DoubleReply
        {
            Result = request.X + request.Y
        });
    }

    public override Task<DoubleReply> SUB(
        CalcRequest request, ServerCallContext context)
    {
        return Task.FromResult(new DoubleReply
        {
            Result = request.X - request.Y
        });
    }

    public override Task<DoubleReply> MUL(
        CalcRequest request, ServerCallContext context)
    {
        return Task.FromResult(new DoubleReply
        {
            Result = request.X * request.Y
        });
    }

    public override Task<DoubleReply> DIV(
        CalcRequest request, ServerCallContext context)
    {
        if (request.Y == 0)
        {
            throw new RpcException(
                new Status(StatusCode.InvalidArgument,
                "Деление на ноль невозможно."));
        }

        return Task.FromResult(new DoubleReply
        {
            Result = request.X / request.Y
        });
    }

    public override Task<IntReply> FACT(
        FactRequest request, ServerCallContext context)
    {
        int x = request.X;

        if (x < 0)
        {
            throw new RpcException(
                new Status(StatusCode.InvalidArgument,
                "Факториал отрицательного числа не определен."));
        }

        int result = 1;

        try
        {
            for (int i = 1; i <= x; i++)
            {
                result = checked(result * i);
            }
        }
        catch (OverflowException)
        {
            throw new RpcException(
                new Status(StatusCode.OutOfRange,
                "Результат факториала превышает размерность int."));
        }

        return Task.FromResult(new IntReply
        {
            Result = result
        });
    }
}
