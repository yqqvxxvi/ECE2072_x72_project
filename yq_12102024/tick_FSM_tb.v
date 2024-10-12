`timescale 1us/1ns
module tick_FSM_tb; // fix this later

	reg [0:0]rst;
	reg [0:0]clk;
	reg [0:0]enable;
	wire [3:0]tick; // output
	
	tick_FSM uut(.rst(rst), .clk(clk), .enable(enable), .tick(tick));
	
	integer pass_count=0;
	
	// generate clock
	always @(*)begin
		#5;
		clk <= ~clk;
	end 
	
	// test sequence
	initial begin
		clk = 0;
		rst = 1; // reset high
		enable = 0;
		
		$display("Time\t clk rst enable tick");
		$monitor("%4d\t %b  %b  %b     %b", $time, clk,rst,enable,tick);
		
		rst = 0; // reset low
		enable = 1; // enable high, start to tick
		
		#10;
		if (tick == 4'b0001) begin
			$display("Test 1 Passed: Tick1 after reset.");
			pass_count = pass_count + 1;
		end else $display("Test 1 Failed: Tick1 after reset.");
		
		#10;
		if (tick == 4'b0010) begin
			$display("Test 2 Passed: Tick1 -> Tick2.");
			pass_count = pass_count + 1;
		end else $display("Test 2 Failed: Tick1 -> Tick2.");

		#10;
		if (tick == 4'b0100) begin
			$display("Test 3 Passed: Tick2 -> Tick3.");
			pass_count = pass_count + 1;
		end else $display("Test 3 Failed: Tick2 -> Tick3.");

		#10;
		if (tick == 4'b1000) begin
			$display("Test 4 Passed: Tick3 -> Tick4.");
			pass_count = pass_count + 1;
		end else $display("Test 4 Failed: Tick3 -> Tick4.");
		
		enable = 0; // enable low, no ticking
		
		if (tick == 4'b1000) begin
			$display("Test 5 Passed: Tick remains the same when enable = 0.");
			pass_count = pass_count + 1;
		end else $display("Test 6 Failed: Tick should remain the same when enable = 0.");
		
		enable = 1; // enable high, test transient, enable 0 --> 1
		
		#20;
		if (tick == 4'b0010) begin
			$display("Test 6 Passed: FSM continues after re-enabling.");
			pass_count = pass_count + 1;
		end else $display("Test 7 Failed: FSM should continue after re-enabling.");
		
		rst = 1; // reset high, test tick to be reset = 0000
		
		#10;
		if (tick == 4'b0001) begin
			$display("Test 7 Passed: FSM resets to Tick1 after reset.");
			pass_count = pass_count + 1;
		end else $display("Test 8 Failed: FSM should reset to Tick1 after reset.");
		
		#10;
		rst = 0; // reset low, test transient, reser 1 --> 0
		
		#40;
		$display("\nTotal Tests Passed: %d/7", pass_count);
		$stop;
	end
endmodule
