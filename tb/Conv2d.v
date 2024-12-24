`timescale 1ns / 1ps
`include "tb/ConvKernel.v"

module Conv2d #(
    parameter integer N = 24,
    parameter integer Q = 13,
    parameter integer w = 6,
    parameter integer h = 6,
    parameter integer c = 1,
    
    parameter integer p = 1
    )
    (
    input clk,
    input [N * w * h * c - 1 : 0]data,
    input [N * 3 * 3 * c - 1 : 0]filterWeight,
    input [N - 1 : 0] filterBias,
    output reg [N * (w-2+2*p) * (h-2+2*p) - 1 : 0] result
    );
    
    wire [N-1 : 0] dataArray[0:c-1][0:h-1][0:w-1];
    wire [N-1 : 0] dataArrayWithPadding[0:c-1][0:h+1][0:w+1];
    wire [N*3*3*c-1 : 0] paramArray[0:h-3+2*p][0:w-3+2*p];
 
    wire [N * (w-2+2*p) * (h-2+2*p) - 1 : 0] out;
    
    genvar i, j, k, m, n;
    generate       
        for(i = 0; i < c; i = i + 1) begin
            for(j = -1; j <= h; j = j + 1) begin
                if(j==-1 || j==h) begin
                    for(k = 0; k < w; k = k + 1) begin
                        assign dataArrayWithPadding[i][j+1][k+1] = 0;   
                    end
                end
                else begin
                    for(k = 0; k < w; k = k + 1) begin
                        assign dataArray[i][j][k] = data[(i * h * w + j * w + k) * N + N - 1:(i * h * w + j * w + k) * N];
                        assign dataArrayWithPadding[i][j+1][k+1] = dataArray[i][j][k];
                    end
                end
                assign dataArrayWithPadding[i][j+1][0] = 0;
                assign dataArrayWithPadding[i][j+1][w+1] = 0;
            end
        end      
    endgenerate
    
    generate
        for(j = 2-p; j <= h-1+p; j = j + 1) begin
            for(k = 2-p; k <= w-1+p; k = k + 1) begin
                for(i = 0; i < c; i = i + 1) begin
                    for(m = j - 1; m <= j + 1; m = m + 1) begin
                        for(n = k - 1; n <= k + 1; n = n + 1) begin
                            assign paramArray[j-2+p][k-2+p][(i*9 + (m-j+1)*3 + (n-k+1)) * N + N - 1:(i*9 + (m-j+1)*3 + (n-k+1)) * N] = 
                                dataArrayWithPadding[i][m][n]; 
                        end
                    end
                end
            end
        end
    endgenerate
    
    generate
        for(m = 0; m < h-2+2*p; m = m + 1) begin
            for(n = 0; n < w-2+2*p; n = n + 1) begin
                    //$display("row:%d, col:%d, array:%b, weight:%b", m, n, paramArray[m][n], filterWeight);
                    ConvKernel#(N, Q, c, 3, 3) convKernel(paramArray[m][n], 
                    filterWeight, 
                    filterBias,
                    clk,
                    out[(m * (w-2+2*p) + n) * N + N - 1 : (m * (w-2+2*p) + n) * N]);
            end
        end   
    endgenerate
    
    always @(posedge clk) begin
        result = out;
    end
    
endmodule
