`timescale 1us/1ns

module ALU_tb;
	
	reg signed [15:0] input_a;
	reg signed [15:0] input_b;
	reg [2:0] alu_op;
	wire [15:0] result;

	ALU uut (
		.input_a(input_a),
		.input_b(input_b),
		.alu_op(alu_op),
		.result(result)
	);

	task display_result;
		input [15:0] a, b, res;
		input [2:0] alu_op;
		begin
			case(alu_op)
				3'b000: $display("Multiplication: %d * %d = %d", a, b, res);
				3'b001: $display("Addition: %d + %d = %d", a, b, res);
				3'b010: $display("Subtraction: %d - %d = %d", a, b, res);
				3'b011: $display("Shift: %b shifted by %b --> %b", b, a, res);
				default: $display("Unknown Operation");
			endcase
		end
	endtask

	initial begin
		$display("Starting ALU Testbench");
		
		// Addition
		input_a = 16'd10;
		input_b = 16'd15;
		alu_op = 3'b001;
		#10;
		display_result(input_a, input_b, result, alu_op);
		
		// Subtraction
		input_a = 16'd30;
		input_b = 16'd20;
		alu_op = 3'b010;
		#10;
		display_result(input_a, input_b, result, alu_op);
		
		// Multiplication
		input_a = 16'd5;
		input_b = 16'd6;
		alu_op = 3'b000; 
		#10;
		display_result(input_a, input_b, result, alu_op);
		
		// Left shift (positive input_b)
		input_a = 16'd2;
		input_b = 16'd4;
		alu_op = 3'b011;  // Shift operation
		#10;
		display_result(input_a, input_b, result, alu_op);
		
		// Right shift (negative input_b)
		input_a = -16'd2;  // Negative shift with high bit set
		input_b = 16'd4;
		alu_op = 3'b011;  // Shift operation
		#10;
		display_result(input_a, input_b, result, alu_op);

		/*Edge Cases*/ /*overflow will = to 0*/

		// overflow in addition
		input_a = 16'hFFFF;
		input_b = 16'h0001;
		alu_op = 3'b001;  // Addition
		#10;
		display_result(input_a, input_b, result, alu_op);

		// shift beyond bit-width
		input_a = 16'd20;
		input_b = 16'd5;
		alu_op = 3'b011;  // Shift operation
		#10;
		display_result(input_a, input_b, result, alu_op);

		// multiplication result overflow
		input_a = 16'hFFFF;
		input_b = 16'd10;
		alu_op = 3'b000;  // Multiplication
		#10;
		display_result(input_a, input_b, result, alu_op);

		$display("ALU Testbench completed");
		$stop;
	end

endmodule
