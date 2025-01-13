`timescale 1ns / 1ps
`include "tb/mult.v"
`include "tb/addm.v"
`include "tb/addm4.v"
`include "tb/dot.v"
`include "tb/tanhma.v"
module lstm #(
    parameter M = 16,                   // 矩阵 A 的行数和矩阵 Y 的行数
    parameter N = 32,                   // 矩阵 A 的列数和矩阵 B 的行数
    parameter DATA_WIDTH = 16,         // 矩阵元素的总位宽（包括符号位）
    parameter FRACT_WIDTH = 8          // 矩阵元素的小数位数
)(
    input [M*N*DATA_WIDTH-1:0] Wii,      
    input [M*M*DATA_WIDTH-1:0] Whi,     
    input [M*N*DATA_WIDTH-1:0] Wif,      
    input [M*M*DATA_WIDTH-1:0] Whf,   
    input [M*N*DATA_WIDTH-1:0] Wig,      
    input [M*M*DATA_WIDTH-1:0] Whg,  
    input [M*N*DATA_WIDTH-1:0] Wio,      
    input [M*M*DATA_WIDTH-1:0] Who, 
    input [M*DATA_WIDTH-1:0] bii,   
    input [M*DATA_WIDTH-1:0] bhi,  
    input [M*DATA_WIDTH-1:0] bif,   
    input [M*DATA_WIDTH-1:0] bhf, 
    input [M*DATA_WIDTH-1:0] big,   
    input [M*DATA_WIDTH-1:0] bhg, 
    input [M*DATA_WIDTH-1:0] bio,   
    input [M*DATA_WIDTH-1:0] bho,  
    input wire [M*DATA_WIDTH-1:0] ctI, 
    input wire [M*DATA_WIDTH-1:0] htI,   
    input wire [N*DATA_WIDTH-1:0] xt, 
    output reg [M*DATA_WIDTH-1:0] c_t_out, 
    output reg [M*DATA_WIDTH-1:0] h_t_out,
    input clk
);
    wire [M*DATA_WIDTH-1:0]it; 
    wire [M*DATA_WIDTH-1:0]ft;  
    wire [M*DATA_WIDTH-1:0]gt;   
    wire [M*DATA_WIDTH-1:0]ot;  
    wire [M*DATA_WIDTH-1:0]tempm1;
    wire [M*DATA_WIDTH-1:0]tempm2;
    wire [M*DATA_WIDTH-1:0]tempm3;
    wire [M*DATA_WIDTH-1:0]tempm4; 
    wire [M*DATA_WIDTH-1:0]tempm5;
    wire [M*DATA_WIDTH-1:0]tempm6; 
    wire [M*DATA_WIDTH-1:0]tempm7; 
    wire [M*DATA_WIDTH-1:0]tempm8;
    wire [M*DATA_WIDTH-1:0]tempm9;
    wire [M*DATA_WIDTH-1:0]tempm10;
    wire [M*DATA_WIDTH-1:0]tempm11;

    wire [M*DATA_WIDTH-1:0] ctO; 
    wire [M*DATA_WIDTH-1:0] htO;

    matrix_multiplier #(.M(M),.N(N),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult1(
        .a(Wii),.b(xt),.y(tempm1));

    matrix_multiplier #(.M(M),.N(M),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult2(
        .a(Whi),.b(htI),.y(tempm2));

    matrix_adder4 #(
        .H(M),
        .W('b1),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH),
        .logic_type(1'b0)
    ) adder1 (
        .a(tempm1),
        .b(bii),
        .c(tempm2),
        .d(bhi),
        .y(it)
    );

    matrix_multiplier #(.M(M),.N(N),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult3(
        .a(Wif),.b(xt),.y(tempm3));

    matrix_multiplier #(.M(M),.N(M),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult4(
        .a(Whf),.b(htI),.y(tempm4));

    matrix_adder4 #(
        .H(M),
        .W('b1),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH),
        .logic_type(1'b0)
    ) adder2 (
        .a(tempm3),
        .b(bif),
        .c(tempm4),
        .d(bhf),
        .y(ft)
    );

    matrix_multiplier #(.M(M),.N(N),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult5(
        .a(Wig),.b(xt),.y(tempm5));

    matrix_multiplier #(.M(M),.N(M),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult6(
        .a(Whg),.b(htI),.y(tempm6));

    matrix_adder4 #(
        .H(M),
        .W('b1),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH),
        .logic_type(1'b1)
    ) adder3 (
        .a(tempm5),
        .b(big),
        .c(tempm6),
        .d(bhg),
        .y(gt)
    );

    matrix_multiplier #(.M(M),.N(N),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult7(
        .a(Wio),.b(xt),.y(tempm7));

    matrix_multiplier #(.M(M),.N(M),.P('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) mult8(
        .a(Who),.b(htI),.y(tempm8));

    matrix_adder4 #(
        .H(M),
        .W('b1),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH),
        .logic_type(1'b0)
    ) adder4 (
        .a(tempm7),
        .b(bio),
        .c(tempm8),
        .d(bho),
        .y(ot)
    );

    matrix_odoter #(.H(M),.W('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) odot1(
        .a(ft),.b(ctI),.y(tempm9));  
    matrix_odoter #(.H(M),.W('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) odot2(
        .a(it),.b(gt),.y(tempm10));  
    matrix_adder #(
        .H(M),
        .W('b1),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) adder5 (
        .a(tempm9),
        .b(tempm10),
        .y(ctO)
    );
    matrix_tanhr #(.H(M),.W('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) tanh1(
        .a(ctO),.y(tempm11));  
    matrix_odoter #(.H(M),.W('b1),.DATA_WIDTH(DATA_WIDTH), .FRACT_WIDTH(FRACT_WIDTH) ) odot3(
        .a(ot),.b(tempm11),.y(htO));  

    initial begin
        c_t_out <= 0;
        h_t_out <= 0;
    end

    always @(posedge clk) begin
        c_t_out <= ctO;
		h_t_out <= htO;
    end

endmodule
