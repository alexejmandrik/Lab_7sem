
package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	pb "example.com/grpcclient02/proto"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"
)

func readFloat(reader *bufio.Reader, message string) float64 {
	fmt.Print(message)

	input, _ := reader.ReadString('\n')
	value, err := strconv.ParseFloat(strings.TrimSpace(input), 64)

	if err != nil {
		fmt.Println("Ошибка: необходимо ввести число.")
		os.Exit(1)
	}

	return value
}

func readInt(reader *bufio.Reader, message string) int32 {
	fmt.Print(message)

	input, _ := reader.ReadString('\n')
	value, err := strconv.ParseInt(strings.TrimSpace(input), 10, 32)

	if err != nil {
		fmt.Println("Ошибка: необходимо ввести целое число типа int32.")
		os.Exit(1)
	}

	return int32(value)
}

func createContext() (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), 5*time.Second)
}

func printError(method string, err error) {
	rpcStatus, ok := status.FromError(err)

	if ok {
		fmt.Printf(
			"Ошибка %s: %s (код: %s)\n",
			method,
			rpcStatus.Message(),
			rpcStatus.Code(),
		)
	} else {
		fmt.Printf("Ошибка %s: %v\n", method, err)
	}
}

func main() {
	reader := bufio.NewReader(os.Stdin)

	fmt.Println("=== gRPC КАЛЬКУЛЯТОР (Go) ===")

	conn, err := grpc.NewClient(
		"127.0.0.1:5000",
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)

	if err != nil {
		fmt.Println("Ошибка подключения:", err)
		return
	}

	defer conn.Close()

	client := pb.NewCalculatorClient(conn)

	fmt.Println("Подключение к серверу выполнено.")

	x := readFloat(reader, "Введите первое число X: ")
	y := readFloat(reader, "Введите второе число Y: ")

	request := &pb.CalcRequest{
		X: x,
		Y: y,
	}

	fmt.Println("\n--- Результаты операций ---")

	ctx, cancel := createContext()
	result, err := client.SUM(ctx, request)
	cancel()

	if err != nil {
		printError("SUM", err)
	} else {
		fmt.Printf("SUM = %v\n", result.Result)
	}

	ctx, cancel = createContext()
	result, err = client.SUB(ctx, request)
	cancel()

	if err != nil {
		printError("SUB", err)
	} else {
		fmt.Printf("SUB = %v\n", result.Result)
	}

	ctx, cancel = createContext()
	result, err = client.MUL(ctx, request)
	cancel()

	if err != nil {
		printError("MUL", err)
	} else {
		fmt.Printf("MUL = %v\n", result.Result)
	}

	ctx, cancel = createContext()
	result, err = client.DIV(ctx, request)
	cancel()

	if err != nil {
		printError("DIV", err)
	} else {
		fmt.Printf("DIV = %v\n", result.Result)
	}

	number := readInt(
		reader,
		"\nВведите число для вычисления факториала: ",
	)

	ctx, cancel = createContext()
	factResult, err := client.FACT(ctx, &pb.FactRequest{
		X: number,
	})
	cancel()

	if err != nil {
		printError("FACT", err)
	} else {
		fmt.Printf("FACT(%d) = %d\n", number, factResult.Result)
	}

	fmt.Println("\nНажмите Enter для завершения...")
	reader.ReadString('\n')
}
