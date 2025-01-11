module sigmoid#(
	parameter DATA_WIDTH = 16,
	parameter FRACT_WIDTH = 8
)(
	input signed [DATA_WIDTH-1:0] X,
	output signed [DATA_WIDTH-1:0] Y
);
	
	wire signed [DATA_WIDTH-1:0] s1;
	assign s1 = X+24'h004000; 
	//(若|x|<=2,Y = 0,否则y = x/4，改位数时要改)
	assign Y = (X[DATA_WIDTH-1]) ? (
		// negative
		(X < -24'h004000)? 24'h000000 : (s1>>>2) ) 
		// positive
		: ( (X>24'h004000) ? 24'h002000: (s1>>>2) );


endmodule
