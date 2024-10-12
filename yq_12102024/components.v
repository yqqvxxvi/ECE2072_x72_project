	/*
	Monash University ECE2072: Assignment 
	This file contains Verilog code to implement individual components to be used in 
		 the CPU.

	Please enter your name and student ID: Liew You Qing 33590400

	*/
	module sign_extend(in, ext);
		/* 
		 * This module sign extends the 9-bit Din to a 16-bit output.
		  assume the MSB is the sign bit, maximum valued bit is 8 bits
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
		parameter TICK1 = 4'b0001;
		parameter TICK2 = 4'b0010;
		parameter TICK3 = 4'b0100;
		parameter TICK4 = 4'b1000;
		
		always @(posedge clk) begin
			if (rst == 1) begin /* no declare condition means initially 0 */
				// reset, return to Tick 1 (0001)
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

		input [15:0] R0;
		input [15:0] R1;
		input [15:0] R2;
		input [15:0] R3;
		input [15:0] R4;
		input [15:0] R5;
		input [15:0] R6;
		input [15:0] R7;
		input [15:0] SignExtDin;
		input [15:0] G;
		input [3:0] sel;
		output reg signed [15:0] Bus;
		
		// TODO: implement logic
		always @(*) begin
			case (sel) /* use blocking input to ensures that the assignment happens immediately within the same time step.*/
				4'b0000: Bus = R0;
				4'b0001: Bus = R1;
				4'b0010: Bus = R2;
				4'b0011: Bus = R3;
				4'b0100: Bus = R4;
				4'b0101: Bus = R5;
				4'b0110: Bus = R6;
				4'b0111: Bus = R7;
				4'b1000: Bus = SignExtDin;
				4'b1001: Bus = G;
				default: Bus = 16'b0;
			endcase
		end
	endmodule

	module ALU (input_a, input_b, alu_op, result);
		 // Input declarations
		 input signed [15:0] input_a;  // First operand (signed 16-bit)
		 input signed [15:0] input_b;  // Second operand (signed 16-bit)
		 input [2:0] alu_op;           // ALU operation code (3-bit)

		 // Output declaration
		 output reg signed [15:0] result; // Result of ALU operation (signed 16-bit)
		 reg signed [31:0] mult_result;
		 
		 // ALU operation based on alu_op
		 always @(*) begin
			  case (alu_op)
					// Multiplication Operation
					3'b100: begin
						 // Declare a temporary 32-bit register to hold the multiplication result
						 mult_result = input_a * input_b; // Perform 16x16 multiplication
						 result = mult_result[15:0];      // Take lower 16 bits as the result
						 // Overflow detection:
						 // If upper 16 bits are not sign extensions of the sign bit,
						 // it indicates an overflow.
						 if (mult_result[31:16] != {16{mult_result[31]}}) begin
							  result = 16'b0; // Overflow occurred; set result to zero
						 end
					end

					// Addition Operation
					3'b001: begin
						 result = input_a + input_b; // Perform addition

						 // Overflow detection:
						 // If input_a and input_b have the same sign, but result has a different sign,
						 // an overflow has occurred.
						 if ((input_a[15] == input_b[15]) && (result[15] != input_a[15])) begin
							  result = 16'b0; // Overflow occurred; set result to zero
						 end
					end

					// Subtraction Operation
					3'b010: begin
						 result = input_a - input_b; // Perform subtraction

						 // Overflow detection:
						 // If input_a and input_b have opposite signs, and result's sign differs from input_a,
						 // an overflow has occurred.
						 if ((input_a[15] != input_b[15]) && (result[15] != input_a[15])) begin
							  result = 16'b0; // Overflow occurred; set result to zero
						 end
					end

					// Signed Shift Operation
					3'b101: begin
						 // Check if shift amount is positive and within range
						 if (input_a >= 0 && input_a < 16) begin
							  // Right arithmetic shift by input_a bits
							  result = input_b >>> input_a[3:0]; // Use lower 4 bits for shift amount
						 end 
						 // Check if shift amount is negative and within range
						 else if (input_a < 0 && input_a > -16) begin
							  // Left shift by -input_a bits
							  result = input_b <<< (-input_a[3:0]); // Use lower 4 bits
						 end 
						 else begin
							  // Invalid shift amount; no shift performed
							  result = input_b; // Preserve original value
						 end
					end

					// Default Case
					default: begin
						 result = 16'b0; // For undefined alu_op codes, set result to zero
					end
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
		output reg [N-1:0] Q = 0;
		
		// TODO: Implement register logic:
		always @(posedge clk) begin
			if (rst) begin // rst is prioritize rst =1 and r_in = 1 at the same time, module will reset
				Q <= {N{1'b0}}; // Reset the register to 0
			end else if (r_in) begin
				Q <= data_in; // Write data_in to the register if r_in is asserted
			end
		end
	endmodule

