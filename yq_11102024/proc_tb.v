`timescale 1us/1ns

module proc_tb;

    // Declare inputs as registers
    reg clk, rst;
    reg [8:0] din;  // Instruction input
    
    // Declare outputs as wires
    wire signed [15:0] bus;
    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [6:0] HEX5;  // To observe tick display

    // Instantiate the processor (Unit Under Test - UUT)
    simple_proc uut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .bus(bus),
        .R0(R0),
        .R1(R1),
        .R2(R2),
        .R3(R3),
        .R4(R4),
        .R5(R5),
        .R6(R6),
        .R7(R7),
        .HEX5(HEX5)
    );

	 
	  // Monitor the values of the registers and bus
    initial begin
        $monitor("Time = %d, R0 = %d, R1 = %d, R2 = %d, R3 = %d, R4 = %d, R5 = %d, R6 = %d, R7 = %d, bus = %d",
                 $time, R0, R1, R2, R3, R4, R5, R6, R7, bus);
    end
	 
	 initial begin
	 // start with movi
		 din = {(3'b111),(3'b000),(3'b011)};
			
		 clk = 0;
		 clk = 1; // tick 1
		 
		 clk = 0;
		 clk = 1; // tick 2
		 
		 din = {(3'b000),(3'b000),(3'b011)}; // value3
		 
		 clk = 0;
		 clk = 1; // tick 3
		 
		 clk = 0;
		 clk = 1; // tick 4
		 
	 // second movi
		 din = {(3'b111),(3'b001),(3'b000)};
			
		 clk = 0;
		 clk = 1; // tick 1
		 
		 clk = 0;
		 clk = 1; // tick 2
		 
		 din = {(3'b000),(3'b000),(3'b101)}; // value 5
		 
		 clk = 0;
		 clk = 1; // tick 3
		 
		 clk = 0;
		 clk = 1; // tick 4		 
		 
		 
		 
	 end
	 
	 
	 
	 
	 
endmodule 
