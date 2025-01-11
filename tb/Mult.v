`timescale 1ns / 1ps

module matrix_multiplier #(
    parameter M = 8,                   // 矩阵 A 的行数和矩阵 Y 的行数
    parameter N = 8,                   // 矩阵 A 的列数和矩阵 B 的行数
    parameter P = 8,                   // 矩阵 B 的列数和矩阵 Y 的列数
    parameter DATA_WIDTH = 16,         // 矩阵元素的总位宽（包括符号位）
    parameter FRACT_WIDTH = 8          // 矩阵元素的小数位数
)(
    input [M*N*DATA_WIDTH-1:0] a,      // M×N 输入矩阵 A（有符号固定点数）
    input [N*P*DATA_WIDTH-1:0] b,      // N×P 输入矩阵 B（有符号固定点数）
    output reg [M*P*DATA_WIDTH-1:0] y // M×P 输出矩阵 Y（有符号固定点数）
);


    // 解包输入矩阵 A 和 B
    // 使用 signed 类型
    reg signed [DATA_WIDTH-1:0] a1 [0:M-1][0:N-1];
    reg signed [DATA_WIDTH-1:0] b1 [0:N-1][0:P-1];
    reg signed [DATA_WIDTH-1:0] y1 [0:M-1][0:P-1];
    reg signed [2*DATA_WIDTH:0] temp;
    integer i, j, k;

    always @(*) begin
        // 解包矩阵 A
        for (i = 0; i < M; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                a1[i][j] = a[(i*N + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end

        // 解包矩阵 B
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < P; j = j + 1) begin
                b1[i][j] = b[(i*P + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end

        // 初始化输出矩阵 Y1
        for (i = 0; i < M; i = i + 1) begin
            for (j = 0; j < P; j = j + 1) begin
                y1[i][j] = 0;
                // 执行矩阵乘法
                for (k = 0; k < N; k = k + 1) begin
                    // 乘法结果，并右移 FRACT_WIDTH 位以保持固定点数精度
                    temp = a1[i][k] * b1[k][j];

                    y1[i][j] = y1[i][j] + (temp >>> FRACT_WIDTH);
                end
            end
        end

        // 打包输出矩阵 Y1 到输出向量 Y
        for (i = 0; i < M; i = i + 1) begin
            for (j = 0; j < P; j = j + 1) begin
                y[(i*P + j)*DATA_WIDTH +: DATA_WIDTH] = y1[i][j];
            end
        end
    end

endmodule
