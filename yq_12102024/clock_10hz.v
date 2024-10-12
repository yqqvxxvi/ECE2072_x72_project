module clock_10hz(
	input CLOCK_50,
	output reg clock_10
);
	integer counter_bit = 0;
	always @(posedge CLOCK_50) begin
		counter_bit <= counter_bit + 1;
			
		clock_10 <= counter_bit[21:21];
		 
	end 
endmodule 