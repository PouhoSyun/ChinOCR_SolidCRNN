`timescale 1ns / 1ps

module matrix_odoter #(
    parameter H = 8,                   // 矩阵 AB 的行数
    parameter W = 8,                   // 矩阵 AB的列数
    parameter DATA_WIDTH = 16,         // 矩阵元素的总位宽（包括符号位）
    parameter FRACT_WIDTH = 8          // 矩阵元素的小数位数
)(
    input [H*W*DATA_WIDTH-1:0] a,      // H×W 输入矩阵 A（有符号固定点数）
    input [H*W*DATA_WIDTH-1:0] b,      // H×W 输入矩阵 B（有符号固定点数）
    output reg [H*W*DATA_WIDTH-1:0] y // H×W 输出矩阵 Y（有符号固定点数）
);


    // 解包输入矩阵 A 和 B
    // 使用 signed 类型
    reg signed [DATA_WIDTH-1:0] a1 [0:H-1][0:W-1];
    reg signed [DATA_WIDTH-1:0] y1 [0:H-1][0:W-1];
    reg signed [DATA_WIDTH-1:0] b1 [0:H-1][0:W-1];
    reg signed [2*DATA_WIDTH:0] temp;
    integer i, j, k;

    always @(*) begin
        // 解包矩阵 A
        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                a1[i][j] = a[(i*W + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end

        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                b1[i][j] = b[(i*W + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end

        // 初始化输出矩阵 Y1
        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                temp = a1[i][j] * b1[i][j];
                y1[i][j] = temp >>> FRACT_WIDTH;
            end
        end

        // 打包输出矩阵 Y1 到输出向量 Y
        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                y[(i*W + j)*DATA_WIDTH +: DATA_WIDTH] = y1[i][j];
            end
        end
    end

endmodule
