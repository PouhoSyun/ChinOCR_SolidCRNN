`timescale 1ns / 1ps
`include "tb/tanh.v"
`include "tb/sigmoid.v"
module matrix_adder4 #(
    parameter H = 8,                   // 矩阵 AB 的行数
    parameter W = 8,                   // 矩阵 AB的列数
    parameter DATA_WIDTH = 16,         // 矩阵元素的总位宽（包括符号位）
    parameter FRACT_WIDTH = 8,         // 矩阵元素的小数位数
    parameter integer logic_type = 1'b0                 //0是sigmoid 1是tanh
)(
    input [H*W*DATA_WIDTH-1:0] a,      // H×W 输入矩阵 A（有符号固定点数）
    input [H*W*DATA_WIDTH-1:0] b,      // H×W 输入矩阵 b（有符号固定点数）
    input [H*W*DATA_WIDTH-1:0] c,      // H×W 输入矩阵 c（有符号固定点数）
    input [H*W*DATA_WIDTH-1:0] d,      // H×W 输入矩阵 d（有符号固定点数）
    output reg [H*W*DATA_WIDTH-1:0] y // H×W 输出矩阵 Y（有符号固定点数）
);


    // 解包输入矩阵 A 和 B
    // 使用 signed 类型
    reg signed [DATA_WIDTH-1:0] a1 [0:H-1][0:W-1];
    wire signed [DATA_WIDTH-1:0] y1 [0:H-1][0:W-1];
    reg signed [DATA_WIDTH-1:0] b1 [0:H-1][0:W-1];
    reg signed [DATA_WIDTH-1:0] c1 [0:H-1][0:W-1];
    reg signed [DATA_WIDTH-1:0] d1 [0:H-1][0:W-1];
    reg signed [DATA_WIDTH-1:0] temp;
    integer i, j, k;

    always @(*) begin
        // 解包矩阵 ABCD
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
        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                c1[i][j] = c[(i*W + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end
        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                d1[i][j] = d[(i*W + j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end

        // 初始化输出矩阵 Y1
       
        
        
        // 打包输出矩阵 Y1 到输出向量 Y
        for (i = 0; i < H; i = i + 1) begin
            for (j = 0; j < W; j = j + 1) begin
                y[(i*W + j)*DATA_WIDTH +: DATA_WIDTH] = y1[i][j];
            end
        end
    end

    generate
        genvar col,row;
        for (row = 0; row < H; row = row + 1) begin
            for (col = 0; col < W; col = col + 1) begin
                if (logic_type == 0) begin
                    sigmoid #(.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) sig(a1[row][col] + b1[row][col] + c1[row][col]+d1[row][col], y1[row][col]);
                end
                else begin
                    tanh #(.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) tanh(a1[row][col] + b1[row][col] + c1[row][col]+d1[row][col], y1[row][col]);
                end
            end
        end
    endgenerate

endmodule
