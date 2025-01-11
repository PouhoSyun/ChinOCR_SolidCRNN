`timescale 1ns / 1ps

module matrix_multiplier #(
    parameter H = 8,                   // 矩阵 A 的行数和矩阵 Y 的行数
    parameter W = 8,                   // 矩阵 A 的列数和矩阵 B 的行数
    parameter P = 8,                   // 矩阵 B 的列数和矩阵 Y 的列数
    parameter DATA_WIDTH = 16,         // 矩阵元素的总位宽（包括符号位）
    parameter FRACT_WIDTH = 8          // 矩阵元素的小数位数
)(
    input [H*W*DATA_WIDTH-1:0] a,      // H×W 输入矩阵 A（有符号固定点数）
    input [W*P*DATA_WIDTH-1:0] b,      // W×P 输入矩阵 B（有符号固定点数）
    output reg [H*P*DATA_WIDTH-1:0] y // H×P 输出矩阵 Y（有符号固定点数）
);


    // 解包输入矩阵 A 和 B
    // 使用 signed 类型
    reg signed [DATA_WIDTH-1:0] a1 [0:H-1][0:W-1];
    reg signed [DATA_WIDTH-1:0] b1 [0:W-1][0:P-1];
    reg signed [DATA_WIDTH-1:0] y1 [0:H-1][0:P-1];
    wire signed [DATA_WIDTH-1:0] temp;
    wire overflow;
    integer i, j, k;

    always @(*) begin
        // 解包矩阵 A
        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                a1[i][j] = a[(i*W + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end

        // 解包矩阵 B
        for (i = 0; i < W; i = i + 1) begin
            for (j = 0; j < P; j = j + 1) begin
                b1[i][j] = b[(i*P + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end

        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < P; j = j + 1) begin
                y[(i*P + j)*DATA_WIDTH +: DATA_WIDTH] = y1[i][j];
            end
        end
    end

    generate
        genvar col,row,num;
        for (row = 0; row < H; row = row + 1) begin
            for (col = 0; col < P; col = col + 1) begin
                // 执行矩阵乘法
                for (num = 0; num < W; num = num + 1) begin
                    qmult#(.N(DATA_WIDTH), .Q(FRACT_WIDTH)) q(a1[row][num], b1[num][col], temp[num], overflow);
                end
            end
        end
    endgenerate


    always@(posedge clk) begin
        for (row = 0; row < H; row = row + 1) begin
            for (col = 0; col < P; col = col + 1) begin
                for (num = 0; num < W; num = num + 1) begin
                    y1[row][col] = y1[row][col] + temp[num];
                end
            end
        end
    end

endmodule
