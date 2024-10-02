`timescale 1us/1ns

module sign_extend_tb;

	// inputs and outputs for the UUT (Unit Under Test)
	reg [8:0] in;
	wire [15:0] ext;

	// array to store test cases
	reg [8:0] input_cases [0:4];  // 5 test cases
	reg [15:0] expected_output_cases [0:4];  // Expected extended values (optional)

	// instantiating
	sign_extend uut (
	.in(in),
	.ext(ext)
	);

	// loop index
	integer i;

	initial begin
	// printing
	$monitor("Time: %0t | in = %b (%0d), ext = %b (%0d)", $time, in, $signed(in), ext, $signed(ext));

	// test cases
	input_cases[0] = 9'b000000101; // 5 in decimal
	input_cases[1] = 9'b111111011; // -5 in decimal (9-bit 2's complement)
	input_cases[2] = 9'b000000000; // 0 in decimal
	input_cases[3] = 9'b011111111; // 255 in decimal
	input_cases[4] = 9'b100000000; // -256 in decimal

	// for verification, expected case
	expected_output_cases[0] = 16'b0000000000000101; // Expected extension of 5
	expected_output_cases[1] = 16'b1111111111111011; // Expected extension of -5
	expected_output_cases[2] = 16'b0000000000000000; // Expected extension of 0
	expected_output_cases[3] = 16'b0000000011111111; // Expected extension of 255
	expected_output_cases[4] = 16'b1111111110000000; // Expected extension of -256

	// applying test case
	$display("Starting the test...");
	for (i = 0; i < 5; i = i + 1) begin
		in = input_cases[i];  // input test case
		#10;  // wait for the result to stabilize

	$display("Test case %0d: Input (9-bit): %b (%0d), Extended (16-bit): %b (%0d)", 
				i, in, $signed(in), ext, $signed(ext));

	if (ext === expected_output_cases[i]) begin
	$display("Test case %0d passed for extended output.", i);
	end else begin
	$display("Test case %0d failed: Expected extended %b (%0d), got %b (%0d)", 
				i, expected_output_cases[i], $signed(expected_output_cases[i]), ext, $signed(ext));
		end

		// Compare the signed values
		if ($signed(in) === $signed(ext)) begin
		$display("Test case %0d passed: Input and Extended output are equal.", i);
		end else begin
		$display("Test case %0d failed: Input (%0d) and Extended output (%0d) are not equal.", 
					i, $signed(in), $signed(ext));
		end
	end

	$display("Test complete.");
	$stop;
  end

endmodule
