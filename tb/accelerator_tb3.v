`timescale 1ns / 1ps
`include "tb/Conv2d.v"

module accelerator_tb;

	// Inputs 输入1个 h = 32  w = 160 的activationmap 和64个3*3的weight

    //ip_file 共有c行，每行共h*w个数，每行表示一个input image
    //weight file 共outchannel行， 每行共c*9个数，每行表示c个 weight image
    //bias file 共outchannel行， 每行1个数
    //out file 共outchannel行，每行共h*w个数，每行表示一个output image
	reg clk;
	reg ce;
	reg [9*N*c-1:0] weight1;
	reg [N-1:0] bias;
	reg global_rst;
	reg [N*h*w*c-1:0] activation;
	parameter N = 24;
	parameter Q = 13;
	parameter h= 8;
	parameter w= 40;
	parameter c= 256;
	parameter p= 1;
    parameter outchannel = 256;
	integer i,ii;
    integer ip_file,weight_file,bias_file,op_file;
    integer r3, r4;

    //outputs 输出64个result map
	wire [N*(h-2+p*2)*(w-2+p*2)-1:0] result;


	// Instantiate the Unit Under Test (UUT)
	Conv2d #(.N(N), .Q(Q), .w(w), .h(h), .c(c), .p(p)) uut (
        .clk(clk),
        .data(activation),
        .filterWeight(weight1),
        .filterBias(bias),
        .result(result)
    );
	
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, accelerator_tb);
    end

    initial begin
        // Initialize Inputs
        clk = 0;
        activation = 0;
        // Wait 100 ns for global reset to finish
        #100;
        activation = 0;
        #60;
        ip_file = $fopen("data_input/cnn_conv3.txt","r");
        weight_file = $fopen("model_para/cnn_conv3_weight.txt","r");
        bias_file = $fopen("model_para/cnn_conv3_bias.txt","r");
        r3 = $fscanf(ip_file,"%b\n",activation);

        for(i=0;i<outchannel;i=i+1) begin
            r3 = $fscanf(weight_file,"%b\n",weight1);
            r4 = $fscanf(bias_file,"%b\n",bias);
            #100;
            $fdisplay(op_file,"%b",result); 
        end
        #100;
        $fdisplay(op_file,"%s%0d","end",0);
        #10;
        $finish;
    end

    always #(10) clk = ~clk;  
    

    // 在初始块中打开opfile
    initial begin
        op_file = $fopen("tb/files/accelerator_tb3.txt", "w");
        if (op_file == 0) begin
                $display("Error: Unable to open file for index %0d", i);
                $finish;
        end
    end

endmodule