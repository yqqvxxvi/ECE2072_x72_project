/*
Monash University ECE2072: Assignment 
This file contains Verilog code to implement individual components to be used in 
    the CPU.

Please enter your name and student ID: Liew You Qing 33590400

*/
module sign_extend(in, ext);
	/* 
	 * This module sign extends the 9-bit Din to a 16-bit output.
	 */
	// TODO: Declare inputs and outputs
	input [8:0] in;
	output[15:0] ext;
	
	wire [8:0] in;
	wire [15:0] ext;
	// TODO: implement logic
	assign ext = {{7{in[8]}}, in};
endmodule


module tick_FSM(rst, clk, enable, tick);
	/* 
	 * This module implements a tick FSM that will be used to
	 * control the actions of the control unit
	 */

	// TODO: Declare inputs and outputs
	input wire rst;
	input wire clk;
	input wire enable;
	output reg [3:0]tick;
	
	// TODO: implement FSM
	parameter TICK1 = 4'b1000;
	parameter TICK2 = 4'b0100;
	parameter TICK3 = 4'b0010;
	parameter TICK4 = 4'b0001;

	always @(posedge clk) begin
		if (rst == 1) begin /* no declare condition means initially 0 */
			// reset, return to Tick 1 (1000)
			tick <= TICK1;
		end
		else if (enable == 1) begin	
			// When enable is high and rst is low, transition between ticks
			case (tick)
				TICK1: tick <= TICK2; // Tick 1 -> Tick 2
				TICK2: tick <= TICK3; // Tick 2 -> Tick 3
				TICK3: tick <= TICK4; // Tick 3 -> Tick 4
				TICK4: tick <= TICK1; // Tick 4 -> Tick 1 (wrap around)
				default: tick <= TICK1; 
			endcase
		end
	end
endmodule

module multiplexer(SignExtDin, R0, R1, R2, R3, R4, R5, R6, R7, G, sel, Bus);
	/* 
	 * This module takes 10 inputs and places the correct input onto the bus.
	 */
	// TODO: Declare inputs and outputs
	input [15:0] SignExtDin;  // extended 9-bit DIN (now 16-bit)
	input [15:0] R0;          // register 0
	input [15:0] R1;          // register 1
	input [15:0] R2;          // 2
	input [15:0] R3;          // 3
	input [15:0] R4;          // 4
	input [15:0] R5;          // 5
	input [15:0] R6;          // 6
	input [15:0] R7;          // 7
	input [15:0] G;           // G
	input [3:0] sel;          // selection
	output reg [15:0] Bus;     // 16-bit output to the bus
	
	// TODO: implement logic
	always begin
		case (sel)
			4'b0000: Bus = R0;        // select register 0
			4'b0001: Bus = R1;        // select register 1
			4'b0010: Bus = R2;        // select register 2
			4'b0011: Bus = R3;        // select register 3
			4'b0100: Bus = R4;        // select register 4
			4'b0101: Bus = R5;        // select register 5
			4'b0110: Bus = R6;        // select register 6
			4'b0111: Bus = R7;        // select register 7
			4'b1000: Bus = SignExtDin; // select SignExtDin
			4'b1001: Bus = G;          // select G
			default: Bus = 16'h0000;  // default output if invalid sel
		endcase
	end

endmodule

module ALU (input_a, input_b, alu_op, result);
	/* 
	 * This module implements the arithmetic logic unit of the processor.
	 */
	// TODO: declare inputs and outputs
	input [15:0] input_a;
	input [15:0] input_b;
	input [2:0] alu_op;
	output reg [15:0] result;
	
	// TODO: Implement ALU Logic:
	always begin
		case (alu_op)
				3'b000: result = input_a * input_b;      // multiplication
				3'b001: result = input_a + input_b;      // addition
				3'b010: result = input_a - input_b;      // subtraction
				3'b011: 
					if (input_a[15] == 1'b0) begin
						// +ve left shifting (<</>> always fill with zero)
						result = input_b << input_a;
					end else begin
						// -ve right shift (fill with 0s)
						result = input_b >> input_a;
					end
				default: result = 16'b0; 
		endcase
	end
endmodule



module register_n(data_in, r_in, clk, Q, rst);
	// To set parameter N during instantiation, you can use:
	// register_n #(.N(num_bits)) reg_IR(.....), 
	// where num_bits is how many bits you want to set N to
	// and "..." is your usual input/output signals

	parameter N = 16;

	/* 
	 * This module implements registers that will be used in the processor.
	 */
	// TODO: Declare inputs, outputs, and parameter:
	input [N-1:0] data_in;
	input r_in;
	input clk;
	input rst;
	output reg [N-1:0] Q;
	
	// TODO: Implement register logic:
		always @(posedge clk) begin
		if (rst == 1) begin
			Q <= {N{1'b0}};  // Reset the register to 0
		end else if (r_in == 1) begin
			Q <= data_in;    // Write data_in to the register if r_in is asserted
		end
	end
endmodule

