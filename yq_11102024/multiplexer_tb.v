`timescale 1us/1ns

module multiplexer_tb;
	
	reg [15:0] SignExtDin;
	reg [15:0] R0;
	reg [15:0] R1;
	reg [15:0] R2;
	reg [15:0] R3;
	reg [15:0] R4;
	reg [15:0] R5;
	reg [15:0] R6;
	reg [15:0] R7;
	reg [15:0] G;
	reg [3:0] sel;

	wire [15:0] Bus;
	
	multiplexer uut (
		.SignExtDin(SignExtDin),
		.R0(R0),
		.R1(R1),
		.R2(R2),
		.R3(R3),
		.R4(R4),
		.R5(R5),
		.R6(R6),
		.R7(R7),
		.G(G),
		.sel(sel),
		.Bus(Bus)
	);
	
	integer i;
	
		
	initial begin
		R0 <= 16'hAAAA;
		R1 <= 16'hBBBB;
		R2 <= 16'hCCCC;
		R3 <= 16'hDDDD;
		R4 <= 16'hEEEE;
		R5 <= 16'hFFFF;
		R6 <= 16'h1111;
		R7 <= 16'h2222;
		SignExtDin <= 16'h3333;
		G <= 16'h4444;
		
		$monitor("Time=%0t | sel=%0x | R0=%0x R1=%0x R2=%0x R3=%0x R4=%0x R5=%0x R6=%0x R7=%0x G=%0x SignExtDin=%0x Bus=%0x", 
					$time, sel, R0, R1, R2, R3, R4, R5, R6, R7, G, SignExtDin, Bus);
		
		// sel values from 0 to 9
		for (i = 0; i < 4'b1001; i = i + 1) begin
			#10 sel = i;
		end
		
		#10 
		$stop;
	end
endmodule
