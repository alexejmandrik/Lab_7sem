
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const path = require('path');

const PROTO_PATH = path.join(__dirname, 'protos', 'calculator.proto');

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
    keepCase: false,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true
});

const calculatorProto = grpc.loadPackageDefinition(packageDefinition).calculator;

const calculator = {
    SUM: (call, callback) => {
        callback(null, { result: call.request.x + call.request.y });
    },

    SUB: (call, callback) => {
        callback(null, { result: call.request.x - call.request.y });
    },

    MUL: (call, callback) => {
        callback(null, { result: call.request.x * call.request.y });
    },

    DIV: (call, callback) => {
        const { x, y } = call.request;

        if (y === 0) {
            return callback({
                code: grpc.status.INVALID_ARGUMENT,
                message: 'Деление на ноль невозможно.'
            });
        }

        callback(null, { result: x / y });
    },

    FACT: (call, callback) => {
        const x = call.request.x;

        if (x < 0) {
            return callback({
                code: grpc.status.INVALID_ARGUMENT,
                message: 'Факториал отрицательного числа не определен.'
            });
        }

        let result = 1;

        for (let i = 1; i <= x; i++) {
            result *= i;

            if (result > 2147483647) {
                return callback({
                    code: grpc.status.OUT_OF_RANGE,
                    message: 'Результат факториала превышает размерность int32.'
                });
            }
        }

        callback(null, { result });
    }
};

const server = new grpc.Server();

server.addService(calculatorProto.Calculator.service, calculator);

server.bindAsync(
    '0.0.0.0:5000',
    grpc.ServerCredentials.createInsecure(),
    (error, port) => {
        if (error) {
            console.error('Ошибка запуска сервера:', error);
            return;
        }

        console.log(`gRPC Server 02 запущен на порту ${port}`);
    }
);
