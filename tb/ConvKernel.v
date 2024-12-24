`timescale 1ns / 1ps
`include "tb/qmult.v"

module ConvKernel#(
    parameter integer N = 25,
    parameter integer Q = 14,  
    
    parameter integer DATACHANNEL = 1, 
    
    parameter integer FILTERHEIGHT = 3,
    parameter integer FILTERWIDTH = 3
    )
    (
    input [N * DATACHANNEL * FILTERHEIGHT * FILTERWIDTH - 1 : 0]data,
    input [N * DATACHANNEL * FILTERHEIGHT * FILTERWIDTH - 1 : 0]weight,
    input [N - 1:0] bias,
    input clk,
    output [N -1 : 0]result
    );
    
    wire signed [N - 1 : 0] out [FILTERHEIGHT * FILTERWIDTH * DATACHANNEL - 1 : 0];
    reg signed [N -1 : 0]result;
    wire overflow;
    
    generate
        genvar i;
        for(i = 0; i < FILTERHEIGHT * FILTERWIDTH * DATACHANNEL; i = i + 1) begin
            qmult#(.N(N), .Q(Q)) q(data[(i + 1) * N - 1 : i * N], weight[(i + 1) * N - 1 : i * N], out[i], overflow);
        end
    endgenerate
    
    integer j;
    always @(negedge clk) begin
        result = 0;
        for(j = 0; j < FILTERHEIGHT * FILTERWIDTH * DATACHANNEL; j = j + 1) begin
            result = result + out[j];
        end
        result = result + bias;
    end
    
endmodule
