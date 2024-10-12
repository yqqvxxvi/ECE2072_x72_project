/*
Monash University ECE2072: Assignment 
This file contains Verilog code to implement individual the CPU.

Please enter your student ID: Liew You Qing 33590400
*/

module simple_proc(
	// Declare inputs and outputs:
	input clk, rst,
	input [8:0] din,
	output wire signed [15:0] bus,
	output wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7, // Output ports for registers
	output [6:0] HEX5
	);
		
	// Declare wires:
	wire signed [15:0] A, G;
	wire signed [15:0] ext_din;
	wire signed [15:0] alu_result;
	wire [2:0] alu_op;
	wire [3:0] tick;
	wire signed [15:0] mux_out;
	wire [8:0] IR; // Current instruction (internal wire)
		
	// Enable signals for registers and ALU
	reg RA_enable, RG_enable, RI_enable;
	reg R0_enable, R1_enable, R2_enable, R3_enable, R4_enable, R5_enable, R6_enable, R7_enable;
	reg [3:0] mux_sel;
	reg [2:0] reg_x, reg_y;
	reg [2:0] opcode; // operation
	reg signed [8:0] immediate_reg; // Holds the immediate value for MOVI and ADDI
	reg [2:0] alu_op_reg; // Register to hold the mapped alu_op
	reg [3:0] tick_bcd;
		
		
	parameter N = 16;
		
	// Parameters for mux_sel
	parameter SEL_R0 = 4'b0000;
	parameter SEL_R1 = 4'b0001;
	parameter SEL_R2 = 4'b0010;
	parameter SEL_R3 = 4'b0011;
	parameter SEL_R4 = 4'b0100;
	parameter SEL_R5 = 4'b0101;
	parameter SEL_R6 = 4'b0110;
	parameter SEL_R7 = 4'b0111;
	parameter SEL_IMMEDIATE = 4'b1000;  // For immediate value (SignExtDin)
	parameter SEL_G  = 4'b1001;
		
	// Parameters for enabling signal
	parameter ena_R0 = 3'b000;
	parameter ena_R1 = 3'b001;
	parameter ena_R2 = 3'b010;
	parameter ena_R3 = 3'b011;
	parameter ena_R4 = 3'b100;
	parameter ena_R5 = 3'b101;
	parameter ena_R6 = 3'b110;
	parameter ena_R7 = 3'b111;
		
	// Parameters for OPCODE
	parameter MOVI_OP = 3'b111;  // MOVI Immediate
	parameter ADDI_OP = 3'b010;  // ADD Immediate
	parameter ADD_OP  = 3'b001;  // ADD (Rx + Ry)
	parameter SUB_OP  = 3'b011;  // SUB (Rx - Ry)
		
	assign alu_op = alu_op_reg; // Use alu_op_reg in ALU instantiation
	assign bus = mux_out;
		
	// Sign extension for immediate value
	sign_extend s_ext(.in(immediate_reg), .ext(ext_din));
		
	// Instantiate registers:
	// Instruction register
	register_n #(.N(9)) reg_IR(.data_in(din), .r_in(RI_enable), .clk(clk), .Q(IR), .rst(rst)); 
	// General purpose registers
	register_n #(.N(N)) reg0(.data_in(bus), .r_in(R0_enable), .clk(clk), .Q(R0), .rst(rst)); 
	register_n #(.N(N)) reg1(.data_in(bus), .r_in(R1_enable), .clk(clk), .Q(R1), .rst(rst));
	register_n #(.N(N)) reg2(.data_in(bus), .r_in(R2_enable), .clk(clk), .Q(R2), .rst(rst));
	register_n #(.N(N)) reg3(.data_in(bus), .r_in(R3_enable), .clk(clk), .Q(R3), .rst(rst));
	register_n #(.N(N)) reg4(.data_in(bus), .r_in(R4_enable), .clk(clk), .Q(R4), .rst(rst));
	register_n #(.N(N)) reg5(.data_in(bus), .r_in(R5_enable), .clk(clk), .Q(R5), .rst(rst));
	register_n #(.N(N)) reg6(.data_in(bus), .r_in(R6_enable), .clk(clk), .Q(R6), .rst(rst));
	register_n #(.N(N)) reg7(.data_in(bus), .r_in(R7_enable), .clk(clk), .Q(R7), .rst(rst));
	// A and G registers
	register_n #(.N(N)) regA(.data_in(bus), .r_in(RA_enable), .clk(clk), .Q(A), .rst(rst)); // A register
	register_n #(.N(N)) regG(.data_in(alu_result), .r_in(RG_enable), .clk(clk), .Q(G), .rst(rst)); // G register

  // Instantiate Multiplexer:
	multiplexer mux(
		.R0(R0), .R1(R1), .R2(R2), .R3(R3), 
		.R4(R4), .R5(R5), .R6(R6), .R7(R7), 
		.G(G), .SignExtDin(ext_din), 
		.sel(mux_sel), .Bus(mux_out)
	);

	// Instantiate ALU:
	ALU alu(.input_a(A), .input_b(bus), .alu_op(alu_op), .result(alu_result));

	// Instantiate tick counter:
	tick_FSM tick_fsm(.rst(rst), .clk(clk), .enable(1'b1), .tick(tick));

	// Instantiate BCD decoder to display tick_FSM value on HEX5
	BCD tick_hex5 (
		.A(tick_bcd[3]), .B(tick_bcd[2]), .C(tick_bcd[1]), .D(tick_bcd[0]),
		.a(HEX5[0]), .b(HEX5[1]), .c(HEX5[2]), .d(HEX5[3]),
		.e(HEX5[4]), .f(HEX5[5]), .g(HEX5[6])
	);

	// CONTROL UNIT
	always @(posedge clk or posedge rst) begin
		// Default reset control signals at each clock cycle (tick)
		RA_enable <= 1'b0;
		RG_enable <= 1'b0;
		R0_enable <= 1'b0;
		R1_enable <= 1'b0;
		R2_enable <= 1'b0;
		R3_enable <= 1'b0;
		R4_enable <= 1'b0;
		R5_enable <= 1'b0;
		R6_enable <= 1'b0;
		R7_enable <= 1'b0;
		mux_sel <= 4'b1111;
		case (tick)
			// Tick 1: Instruction Fetch
			4'b0001: begin
				tick_bcd <= 4'b0001;
				RI_enable <= 1'b1;  // Load instruction into IR
				opcode <= IR[8:6];  // Decode opcode from IR
				reg_x  <= IR[5:3];  // Decode reg_x from IR
				reg_y  <= IR[2:0];  // Decode reg_y from IR
			end

			// Tick 2: Operand Fetch / Immediate Handling
			4'b0010: begin
				tick_bcd <= 4'b0010;
				RI_enable <= 1'b0;  // Disable instruction register write

				// Handle immediate values for MOVI and ADDI
				case (opcode)
					MOVI_OP: begin// MOVI (move immediate) 
						immediate_reg <= din; 
						mux_sel <= SEL_IMMEDIATE;
							case (reg_x)  // Enable the destination register
								ena_R0: R0_enable <= 1'b1;
								ena_R1: R1_enable <= 1'b1;
								ena_R2: R2_enable <= 1'b1;
								ena_R3: R3_enable <= 1'b1;
								ena_R4: R4_enable <= 1'b1;
								ena_R5: R5_enable <= 1'b1;
								ena_R6: R6_enable <= 1'b1;
								ena_R7: R7_enable <= 1'b1;
							endcase
						end

					ADDI_OP:  begin // ADDI (add immediate)
						immediate_reg <= din;  
						mux_sel <= SEL_IMMEDIATE;
						RA_enable <= 1'b1;
					end

					ADD_OP: begin // ADD (RX Ry)
						RA_enable <= 1'b1;  // Select Rx and mux_sel to reg A
							case (reg_x)
								ena_R0: mux_sel <= SEL_R0;
								ena_R1: mux_sel <= SEL_R1;
								ena_R2: mux_sel <= SEL_R2;
								ena_R3: mux_sel <= SEL_R3;
								ena_R4: mux_sel <= SEL_R4;
								ena_R5: mux_sel <= SEL_R5;
								ena_R6: mux_sel <= SEL_R6;
								ena_R7: mux_sel <= SEL_R7;
							endcase
						end

					SUB_OP: begin // SUB (Rx Ry)
						RA_enable <= 1'b1;
							case (reg_x)
								ena_R0: mux_sel <= SEL_R0;
								ena_R1: mux_sel <= SEL_R1;
								ena_R2: mux_sel <= SEL_R2;
								ena_R3: mux_sel <= SEL_R3;
								ena_R4: mux_sel <= SEL_R4;
								ena_R5: mux_sel <= SEL_R5;
								ena_R6: mux_sel <= SEL_R6;
								ena_R7: mux_sel <= SEL_R7;
							endcase
						end
						
				endcase
			end	

			// Tick 3: Operand Fetch / Prepare for ALU Operations
			4'b0100: begin
				tick_bcd <= 4'b0011;

				case (opcode)
					// MOVI: Stay idle
					MOVI_OP: begin
						// stay idle
						// i have had enough
					end

					// ADDI: load the Rx onto the bus(input b)
					ADDI_OP: begin
						alu_op_reg <= ADD_OP;
						RG_enable <= 1'b1;
						case (reg_x)
							ena_R0: mux_sel <= SEL_R0;
							ena_R1: mux_sel <= SEL_R1;
							ena_R2: mux_sel <= SEL_R2;
							ena_R3: mux_sel <= SEL_R3;
							ena_R4: mux_sel <= SEL_R4;
							ena_R5: mux_sel <= SEL_R5;
							ena_R6: mux_sel <= SEL_R6;
							ena_R7: mux_sel <= SEL_R7;
						endcase
					end

					 // ADD: Select Ry and mux_sel to bus for ALU
					 ADD_OP: begin
						alu_op_reg <= ADD_OP;
						RG_enable <= 1'b1;
						case (reg_y)
							ena_R0: mux_sel <= SEL_R0;
							ena_R1: mux_sel <= SEL_R1;
							ena_R2: mux_sel <= SEL_R2;
							ena_R3: mux_sel <= SEL_R3;
							ena_R4: mux_sel <= SEL_R4;
							ena_R5: mux_sel <= SEL_R5;
							ena_R6: mux_sel <= SEL_R6;
							ena_R7: mux_sel <= SEL_R7;
						endcase
					end

					// SUB: Prepare Rx and Ry for ALU subtraction
					SUB_OP: begin
						alu_op_reg <= SUB_OP;
						RG_enable <= 1'b1;
						case (reg_y)
							ena_R0: mux_sel <= SEL_R0;
							ena_R1: mux_sel <= SEL_R1;
							ena_R2: mux_sel <= SEL_R2;
							ena_R3: mux_sel <= SEL_R3;
							ena_R4: mux_sel <= SEL_R4;
							ena_R5: mux_sel <= SEL_R5;
							ena_R6: mux_sel <= SEL_R6;
							ena_R7: mux_sel <= SEL_R7;
						endcase
					end
				endcase
			end

			// Tick 4: Write-Back to Register
			4'b1000: begin
				tick_bcd <= 4'b0100;

				case (opcode)
					MOVI_OP: begin
						// stay idle again8
						// i have had enough
					end

					// ADDI: Add immediate to Rx and store result in Rx
					ADDI_OP: begin
						mux_sel <= SEL_G; // mux_sel G
						case (reg_x)  // Write-back to Rx
							ena_R0: R0_enable <= 1'b1;
							ena_R1: R1_enable <= 1'b1;
							ena_R2: R2_enable <= 1'b1;
							ena_R3: R3_enable <= 1'b1;
							ena_R4: R4_enable <= 1'b1;
							ena_R5: R5_enable <= 1'b1;
							ena_R6: R6_enable <= 1'b1;
							ena_R7: R7_enable <= 1'b1;
						endcase
					end

					// ADD: Add Ry to Rx and store result in Rx
					ADD_OP: begin
						mux_sel <= SEL_G; // mux_sel G
						case (reg_x)  // Enable the destination register (Rx)
							ena_R0: R0_enable <= 1'b1;
							ena_R1: R1_enable <= 1'b1;
							ena_R2: R2_enable <= 1'b1;
							ena_R3: R3_enable <= 1'b1;
							ena_R4: R4_enable <= 1'b1;
							ena_R5: R5_enable <= 1'b1;
							ena_R6: R6_enable <= 1'b1;
							ena_R7: R7_enable <= 1'b1;
						endcase
					end

					// SUB: Store result in Rx
					SUB_OP: begin
						RG_enable <= 1'b1;
						mux_sel <= SEL_G; // mux_sel G
						case (reg_x)  // Enable the destination register (Rx)
							ena_R0: R0_enable <= 1'b1;
							ena_R1: R1_enable <= 1'b1;
							ena_R2: R2_enable <= 1'b1;
							ena_R3: R3_enable <= 1'b1;
							ena_R4: R4_enable <= 1'b1;
							ena_R5: R5_enable <= 1'b1;
							ena_R6: R6_enable <= 1'b1;
							ena_R7: R7_enable <= 1'b1;
						endcase
					end
					endcase
				end
		endcase
	end
endmodule 