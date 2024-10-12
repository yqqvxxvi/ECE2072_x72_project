module proc_extension_inst(
	input [9:0] SW,       // Switches for bus input
	input [1:0] KEY,      // Keys for reset and clock
	output [9:0] LEDR,     // LEDs to show bus output
	output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

	// Declare internal wires
	wire [15:0] bus;
	wire [3:0] tick;
    
	// Processor instance
	simple_proc_extension u_processor(
		.clk(~KEY[1]),    // Correct the bit reference and invert the clock signal
		.rst(~KEY[0]),    // Correct the bit reference and invert the reset signal
		.tick_enable(SW[9]), // Ticking enable
		.din(SW[8:0]),    // Input data from switches
		.bus(bus),        // Connect the bus to the processor
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5),
		.R0(),            // Unused register outputs (for testbench usage only)
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
