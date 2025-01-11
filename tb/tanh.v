module tanh#(
	parameter DATA_WIDTH = 16,
	parameter FRACT_WIDTH = 8
)(
	input signed [DATA_WIDTH-1:0] X,
	output signed [DATA_WIDTH-1:0] Y
);

	//(x<=1,y = 1 改位数时要改)	
	assign Y = (X[DATA_WIDTH-1]) ? (
		// negative
		(X < -24'h002000)? -24'h002000 : X ) 
		// positive
		: ( (X>24'h002000) ? 24'h002000: X );
endmodule
