`timescale 1ns / 1ps


module convolver_tb;

	// Inputs
	reg clk;
	reg ce;
	reg [9*N*c-1:0] weight1;
	reg [N-1:0] bias;
	reg global_rst;
	reg [N*h*w*c-1:0] activation;
	parameter N = 16;
	parameter Q = 8;
	parameter h=3;
	parameter w=4;
	parameter c=2;
	parameter p=1;
	integer i;
	wire [N*(h-2+p*2)*(w-2+p*2)-1:0] result;

	// Outputs

	// Instantiate the Unit Under Test (UUT) assign n = 4, k =3, step = 1;
    
	Conv2d #(
		.N(N),
		.Q(Q),
		.w(w),
		.h(h),
		.c(c),
		.p(p)
	) uut (
		.clk(clk),
		.data(activation),
		.filterWeight(weight1),
		.filterBias(bias),
		.result(result)
	);
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, convolver_tb);
    end

	always begin
		#10
		clk = ~clk;
	end
    task display_matrix;
        input [h*w*N-1:0] matrix;
        integer row, col;
        real value; // 使用 real 类型来存储浮点数值
        begin
            for (row = 0; row < h; row = row + 1) begin
                for (col = 0; col < w; col = col + 1) begin
                    // 提取每个输出元素，并以有符号十进制显示
                     // 提取每个输出元素的固定点数值
                        value = $signed(matrix[row*w*N + col*N +: N]);
                        // 将固定点数值转换为浮点数
                        value = value / (2.0 ** Q);
                        // 以浮点数形式显示
                        $write("%0.2f\t", value);
                end
                $write("\n");
            end
        end
    endtask
	initial begin
		// Initialize Inputs
		weight1 = 0;
		clk =0;
		activation = 0;
		bias = 1;

		// Wait 100 ns for global reset to finish
		#100;
		
		weight1 = 0;
		activation = 0;
        #50;
        #10;	
		weight1 = 'h0300_0200_0100_0000_0100_0300_0200_0000_0100_0300_0200_0100_0000_0100_0300_0200_0000_0100;
		// Initialize Inputs
        for (i = 0; i < h*w; i = i + 1) begin
            activation[i*N +: N] = (i < 4) ? (16'd3 <<< Q) : (-16'sd2 <<<Q); // 前4元素为 +3.0，后面为 2.0
        end
		for (i = h*w; i < 2*h*w; i = i + 1) begin
            activation[i*N +: N] = (i < 4+h*w) ? (16'd3 <<< Q) : (16'd2 <<<Q); // 前4元素为 +3.0，后面为 2.0
        end
		#50;
		display_matrix(result);
		$finish;
	end   
endmodule