`timescale 1us / 1ns

module register_n_tb;

	parameter N = 16;

	reg [N-1:0] data_in;
	reg r_in;
	reg clk;
	reg rst;
	wire [N-1:0] Q;

	register_n #(.N(N)) uut (
		.data_in(data_in),
		.r_in(r_in),
		.clk(clk),
		.rst(rst),
		.Q(Q));
		
	initial begin
	clk = 0;
	end
		
	always @(*) begin
		#5; 
		clk <= ~clk; 
	end
		
	initial begin
		$monitor("Time: %0d | rst: %b | r_in: %b | data_in: %h | Q: %h", $time, rst, r_in, data_in, Q);
		rst = 0;
		data_in = 16'hA1A1;
		#10;
		r_in = 1;
		
		#10; // input new data
		data_in = 16'h1A1A; // data should be update
		
		#10;
		rst = 1; // Q = 0 (should) 
		
		#10;
		data_in = 16'h2A2A;
		r_in = 0; // Q remain 0 (should)
		
		
		#10;
		$stop;
		
	end
endmodule 
