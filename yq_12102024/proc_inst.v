module proc_inst(
	input [8:0] SW,       // Switches for bus input
	input [1:0] KEY,      // Keys for reset and clock
	output [9:0] LEDR,     // LEDs to show bus output
	output [6:0] HEX5
);

	// Declare internal wires
	wire [15:0] bus;
	wire [3:0] tick;
    
	// Processor instance
	simple_proc u_processor (
		.clk(~KEY[1]),    // Correct the bit reference and invert the clock signal
		.rst(~KEY[0]),    // Correct the bit reference and invert the reset signal
		.din(SW[8:0]),    // Input data from switches
		.bus(bus),        // Connect the bus to the processor
		.HEX5(HEX5),
		.R0(),            // Unused register outputs (for textbench usage only)
		.R1(),
		.R2(),
		.R3(),
		.R4(),
		.R5(),
		.R6(),
		.R7()
	);

	// Connect the bottom 10 bits of the bus output to LEDR[9:0]
	assign LEDR[9:0] = bus[9:0];
endmodule
