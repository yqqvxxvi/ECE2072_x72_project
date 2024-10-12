///*
//Monash University ECE2072: Assignment 
//This file contains Verilog code to implement the extended version of CPU.
//
//Please enter your student ID: Liew You Qing 33590400
//*/
//
//module proc_memory(
//	// Declare inputs and outputs:
//	input clock,
//	input clk, rst, tick_enable,
//	reg [8:0] din,
//	output wire signed [15:0] bus,
//	output wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7, // Output ports for registers
//	output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
//	output dp
//	);
//		
//	// Declare wires:
//	wire signed [15:0] A, G;
//	wire signed [15:0] ext_din;
//	wire signed [15:0] alu_result;
//	wire [2:0] alu_op;
//	wire [3:0] tick;
//	wire signed [15:0] mux_out;
//	wire [8:0] IR; // Current instruction (internal wire)
//		
//	// Registers
//	reg RA_enable, RG_enable, RI_enable, RD_enable;
//	reg R0_enable, R1_enable, R2_enable, R3_enable, R4_enable, R5_enable, R6_enable, R7_enable;
//	reg [3:0] mux_sel;
//	reg [2:0] reg_x, reg_y;
//	reg [2:0] opcode; // operation
//	reg signed [8:0] immediate_reg; // Holds the immediate value for MOVI and ADDI
//	reg [2:0] alu_op_reg; // Register to hold the mapped alu_op
//	reg [3:0] tick_bcd;
//	reg [15:0] abs_bus; // absolute value of bus
//	reg dp_enable; // enabling decimal point
//	reg [8:0] PC;
//	
//	// for display
//	wire [3:0] ten_thousands;
//	wire [3:0] thousands;
//	wire [3:0] hundreds;
//	wire [3:0] tens;
//	wire [3:0] ones;
//	wire [15:0] DISP_const;
//	wire [7:0] pc_out; // Output of the PC register
//		
//	parameter N = 16;
//		
//	// Parameters for mux_sel
//	parameter SEL_R0 = 4'b0000;
//	parameter SEL_R1 = 4'b0001;
//	parameter SEL_R2 = 4'b0010;
//	parameter SEL_R3 = 4'b0011;
//	parameter SEL_R4 = 4'b0100;
//	parameter SEL_R5 = 4'b0101;
//	parameter SEL_R6 = 4'b0110;
//	parameter SEL_R7 = 4'b0111;
//	parameter SEL_IMMEDIATE = 4'b1000;  // For immediate value (SignExtDin)
//	parameter SEL_G  = 4'b1001;
//		
//	// Parameters for enabling signal
//	parameter ena_R0 = 3'b000;
//	parameter ena_R1 = 3'b001;
//	parameter ena_R2 = 3'b010;
//	parameter ena_R3 = 3'b011;
//	parameter ena_R4 = 3'b100;
//	parameter ena_R5 = 3'b101;
//	parameter ena_R6 = 3'b110;
//	parameter ena_R7 = 3'b111;
//		
//	// Parameters for OPCODE
//	parameter DISP_OP = 3'b000;  // DISP Rx on HEX (dec)
//	parameter ADD_OP  = 3'b001;  // ADD (Rx + Ry)
//	parameter ADDI_OP = 3'b010;  // ADD Immediate
//	parameter SUB_OP  = 3'b011;  // SUB (Rx - Ry)
//	parameter MUL_OP  = 3'b100;  // MUL (Rx * Ry)
//	parameter SSI_OP  = 3'b101;  // SSI Immediate
//	parameter MOVI_OP = 3'b111;  // MOVI Immediate
//	parameter BEZ_OP  = 3'b110;  // branch equal zero for Turing complete only
//	
//	// CLOCK 10Hz
//	wire clock_10;
//	
//	ROM intrsution_memory(.address(PC), .clock(clk), .q(din));
//		
//	// Sign extension for immediate value
//	sign_extend s_ext(.in(immediate_reg), .ext(ext_din));
//		
//	// Instantiate registers:
//	// Instruction register
//	register_n #(.N(9)) reg_IR(.data_in(din), .r_in(RI_enable), .clk(clk), .Q(IR), .rst(rst)); 
//	// General purpose registers
//	register_n #(.N(N)) reg0(.data_in(bus), .r_in(R0_enable), .clk(clk), .Q(R0), .rst(rst)); 
//	register_n #(.N(N)) reg1(.data_in(bus), .r_in(R1_enable), .clk(clk), .Q(R1), .rst(rst));
//	register_n #(.N(N)) reg2(.data_in(bus), .r_in(R2_enable), .clk(clk), .Q(R2), .rst(rst));
//	register_n #(.N(N)) reg3(.data_in(bus), .r_in(R3_enable), .clk(clk), .Q(R3), .rst(rst));
//	register_n #(.N(N)) reg4(.data_in(bus), .r_in(R4_enable), .clk(clk), .Q(R4), .rst(rst));
//	register_n #(.N(N)) reg5(.data_in(bus), .r_in(R5_enable), .clk(clk), .Q(R5), .rst(rst));
//	register_n #(.N(N)) reg6(.data_in(bus), .r_in(R6_enable), .clk(clk), .Q(R6), .rst(rst));
//	register_n #(.N(N)) reg7(.data_in(bus), .r_in(R7_enable), .clk(clk), .Q(R7), .rst(rst));
//	// A and G registers
//	register_n #(.N(N)) regA(.data_in(bus), .r_in(RA_enable), .clk(clk), .Q(A), .rst(rst)); // A register
//	register_n #(.N(N)) regG(.data_in(alu_result), .r_in(RG_enable), .clk(clk), .Q(G), .rst(rst)); // G register
//	// Mux out register
//	register_n #(.N(N)) regDisp(.data_in(abs_bus), . r_in(RD_enable), .clk(clk), .Q(DISP_const), .rst(rst));
//	
//	// Instantiate Multiplexer:
//	multiplexer mux(
//		.R0(R0), .R1(R1), .R2(R2), .R3(R3), 
//		.R4(R4), .R5(R5), .R6(R6), .R7(R7), 
//		.G(G), .SignExtDin(ext_din), 
//		.sel(mux_sel), .Bus(mux_out)
//	);
//
//	// Instantiate ALU:
//	ALU alu(.input_a(A), .input_b(bus), .alu_op(alu_op), .result(alu_result));
//
//	// Instantiate tick counter:
//	tick_FSM tick_fsm(.rst(rst), .clk(clk), .enable(tick_enable), .tick(tick));
//	
//	// Instantiate binary to BCD
//	binary_to_bcd b_to_bcd( .binary(DISP_const), .ten_thousands(ten_thousands), .thousands(thousands), 
//		.hundreds(hundreds), .tens(tens), .ones(ones)
//	);
//	
//	// Instantiate BCD decoder to display the value on the bus (mux_out)
//	BCD ones_display(
//		.A(ones[3]), .B(ones[2]), .C(ones[1]), .D(ones[0]),
//		.dp_enable(dp_enable), .a(HEX0[0]), .b(HEX0[1]), .c(HEX0[2]), .d(HEX0[3]),
//		.e(HEX0[4]), .f(HEX0[5]), .g(HEX0[6]), .dp(HEX0[7])
//	);
//
//	BCD tens_display(
//		.A(tens[3]), .B(tens[2]), .C(tens[1]), .D(tens[0]),
//		.dp_enable(dp_enable), .a(HEX1[0]), .b(HEX1[1]), .c(HEX1[2]), .d(HEX1[3]),
//		.e(HEX1[4]), .f(HEX1[5]), .g(HEX1[6]), .dp(HEX1[7])
//	);
//
//	BCD hundreds_display(
//		.A(hundreds[3]), .B(hundreds[2]), .C(hundreds[1]), .D(hundreds[0]),
//		.dp_enable(dp_enable), .a(HEX2[0]), .b(HEX2[1]), .c(HEX2[2]), .d(HEX2[3]),
//		.e(HEX2[4]), .f(HEX2[5]), .g(HEX2[6]), .dp(HEX2[7])
//		);
//
//	BCD thousands_display(
//		.A(thousands[3]), .B(thousands[2]), .C(thousands[1]), .D(thousands[0]),
//		.dp_enable(dp_enable), .a(HEX3[0]), .b(HEX3[1]), .c(HEX3[2]), .d(HEX3[3]),
//		.e(HEX3[4]), .f(HEX3[5]), .g(HEX3[6]), .dp(HEX3[7])
//		);
//
//	BCD ten_thousands_display(
//		.A(ten_thousands[3]), .B(ten_thousands[2]), .C(ten_thousands[1]), .D(ten_thousands[0]), 
//		.dp_enable(dp_enable), .a(HEX4[0]), .b(HEX4[1]), .c(HEX4[2]), .d(HEX4[3]),
//		.e(HEX4[4]), .f(HEX4[5]), .g(HEX4[6]), .dp(HEX4[7])
//	);
//	// Instantiate BCD decoder to display tick_FSM value on HEX5
//	BCD tick_hex5 (
//		.A(tick_bcd[3]), .B(tick_bcd[2]), .C(tick_bcd[1]), .D(tick_bcd[0]),
//		.dp_enable(dp_enable), .a(HEX5[0]), .b(HEX5[1]), .c(HEX5[2]), .d(HEX5[3]),
//		.e(HEX5[4]), .f(HEX5[5]), .g(HEX5[6]),. dp(HEX5[7])
//	);
//
//	// CONTROL UNIT
//	always @(posedge clk or posedge rst) begin
//		// Default reset control signals at each clock cycle (tick)
//		RA_enable <= 1'b0;
//		RG_enable <= 1'b0;
//		R0_enable <= 1'b0;
//		R1_enable <= 1'b0;
//		R2_enable <= 1'b0;
//		R3_enable <= 1'b0;
//		R4_enable <= 1'b0;
//		R5_enable <= 1'b0;
//		R6_enable <= 1'b0;
//		R7_enable <= 1'b0;
//		case (tick)
//			// Tick 1: Instruction Fetch
//			4'b0001: begin
//				tick_bcd <= 4'b0001;
//				RI_enable <= 1'b1;  // Load instruction into IR
//				opcode <= IR[8:6];  // Decode opcode from IR
//				reg_x  <= IR[5:3];  // Decode reg_x from IR
//				reg_y  <= IR[2:0];  // Decode reg_y from IR
//			end
//
//			// Tick 2: Operand Fetch / Immediate Handling
//			4'b0010: begin
//				tick_bcd <= 4'b0010;
//				RI_enable <= 1'b0;  // Disable instruction register write
//
//				case (opcode)
//					MOVI_OP: begin// MOVI (move immediate) 
//						immediate_reg <= din; 
//						mux_sel <= SEL_IMMEDIATE;
//							case (reg_x)  // Enable the destination register
//								ena_R0: R0_enable <= 1'b1;
//								ena_R1: R1_enable <= 1'b1;
//								ena_R2: R2_enable <= 1'b1;
//								ena_R3: R3_enable <= 1'b1;
//								ena_R4: R4_enable <= 1'b1;
//								ena_R5: R5_enable <= 1'b1;
//								ena_R6: R6_enable <= 1'b1;
//								ena_R7: R7_enable <= 1'b1;
//							endcase
//						end
//
//					// Display selected register value, 5 7segments holding the value
//					DISP_OP: begin 
//						RD_enable <= 1'b1;
//						if (mux_out < 0) begin
//							abs_bus <= -(mux_out); // Calculate the absolute value if mux_out is negative
//							dp_enable <= 1'b1;
//						end else begin
//							abs_bus <= mux_out; // If positive, just assign the mux_out value
//							dp_enable <= 1'b0;
//						end
//							case (reg_x)
//									ena_R0: mux_sel <= SEL_R0;
//									ena_R1: mux_sel <= SEL_R1;
//									ena_R2: mux_sel <= SEL_R2;
//									ena_R3: mux_sel <= SEL_R3;
//									ena_R4: mux_sel <= SEL_R4;
//									ena_R5: mux_sel <= SEL_R5;
//									ena_R6: mux_sel <= SEL_R6;
//									ena_R7: mux_sel <= SEL_R7;
//							endcase // Selecting register to display
//						end
//
//					ADDI_OP:  begin // ADDI (add immediate)
//						immediate_reg <= din;  
//						mux_sel <= SEL_IMMEDIATE;
//						RA_enable <= 1'b1;
//					end
//
//					SSI_OP: begin // Shifting by immediate value, store immediate value into the Reg A
//						immediate_reg <= din;  
//						mux_sel <= SEL_IMMEDIATE;
//						RA_enable <= 1'b1;
//					end
//
//					ADD_OP: begin // ADD (RX Ry)
//						RA_enable <= 1'b1;  // Select Rx and mux_sel to reg A
//							case (reg_x)
//								ena_R0: mux_sel <= SEL_R0;
//								ena_R1: mux_sel <= SEL_R1;
//								ena_R2: mux_sel <= SEL_R2;
//								ena_R3: mux_sel <= SEL_R3;
//								ena_R4: mux_sel <= SEL_R4;
//								ena_R5: mux_sel <= SEL_R5;
//								ena_R6: mux_sel <= SEL_R6;
//								ena_R7: mux_sel <= SEL_R7;
//							endcase
//						end
//
//					SUB_OP: begin // SUB (Rx Ry)
//						RA_enable <= 1'b1;
//							case (reg_x)
//								ena_R0: mux_sel <= SEL_R0;
//								ena_R1: mux_sel <= SEL_R1;
//								ena_R2: mux_sel <= SEL_R2;
//								ena_R3: mux_sel <= SEL_R3;
//								ena_R4: mux_sel <= SEL_R4;
//								ena_R5: mux_sel <= SEL_R5;
//								ena_R6: mux_sel <= SEL_R6;
//								ena_R7: mux_sel <= SEL_R7;
//							endcase
//						end
//
//					MUL_OP: begin // Multiplication, choose Reg x
//						RA_enable <= 1'b1;
//						case (reg_x)
//							 3'b000: mux_sel <= SEL_R0;
//							 3'b001: mux_sel <= SEL_R1;
//							 3'b010: mux_sel <= SEL_R2;
//							 3'b011: mux_sel <= SEL_R3;
//							 3'b100: mux_sel <= SEL_R4;
//							 3'b101: mux_sel <= SEL_R5;
//							 3'b110: mux_sel <= SEL_R6;
//							 3'b111: mux_sel <= SEL_R7;
//						endcase
//					end
//				endcase
//			end	
//
//			// Tick 3: Operand Fetch / Prepare for ALU Operations
//			4'b0100: begin
//				tick_bcd <= 4'b0011;
//
//				case (opcode)
//					// MOVI: Stay idle
//					MOVI_OP: begin
//						// stay idle
//					end
//					
//					DISP_OP: begin
//						// stay idle
//					end
//
//					// ADDI: load the Rx onto the bus(input b)
//					ADDI_OP: begin
//						alu_op_reg <= ADD_OP;
//						RG_enable <= 1'b1;
//						case (reg_x)
//							ena_R0: mux_sel <= SEL_R0;
//							ena_R1: mux_sel <= SEL_R1;
//							ena_R2: mux_sel <= SEL_R2;
//							ena_R3: mux_sel <= SEL_R3;
//							ena_R4: mux_sel <= SEL_R4;
//							ena_R5: mux_sel <= SEL_R5;
//							ena_R6: mux_sel <= SEL_R6;
//							ena_R7: mux_sel <= SEL_R7;
//						endcase
//					end
//
//					//SSI: choose Rx, assign alu_op
//					SSI_OP: begin
//						alu_op_reg <= SSI_OP;
//						RG_enable <= 1'b1;
//						case (reg_x)
//							ena_R0: mux_sel <= SEL_R0;
//							ena_R1: mux_sel <= SEL_R1;
//							ena_R2: mux_sel <= SEL_R2;
//							ena_R3: mux_sel <= SEL_R3;
//							ena_R4: mux_sel <= SEL_R4;
//							ena_R5: mux_sel <= SEL_R5;
//							ena_R6: mux_sel <= SEL_R6;
//							ena_R7: mux_sel <= SEL_R7;
//						endcase
//					end
//
//					// ADD: Select Ry and mux_sel to bus for ALU
//					ADD_OP: begin
//						alu_op_reg <= ADD_OP;
//						RG_enable <= 1'b1;
//						case (reg_y)
//							ena_R0: mux_sel <= SEL_R0;
//							ena_R1: mux_sel <= SEL_R1;
//							ena_R2: mux_sel <= SEL_R2;
//							ena_R3: mux_sel <= SEL_R3;
//							ena_R4: mux_sel <= SEL_R4;
//							ena_R5: mux_sel <= SEL_R5;
//							ena_R6: mux_sel <= SEL_R6;
//							ena_R7: mux_sel <= SEL_R7;
//						endcase
//					end
//
//					// SUB: Ry for ALU subtraction
//					SUB_OP: begin
//						alu_op_reg <= SUB_OP;
//						RG_enable <= 1'b1;
//						case (reg_y)
//							ena_R0: mux_sel <= SEL_R0;
//							ena_R1: mux_sel <= SEL_R1;
//							ena_R2: mux_sel <= SEL_R2;
//							ena_R3: mux_sel <= SEL_R3;
//							ena_R4: mux_sel <= SEL_R4;
//							ena_R5: mux_sel <= SEL_R5;
//							ena_R6: mux_sel <= SEL_R6;
//							ena_R7: mux_sel <= SEL_R7;
//						endcase
//					end
//
//					// MUL: choose Reg Y
//					MUL_OP: begin 
//						alu_op_reg <= MUL_OP;
//						RG_enable <= 1'b1;
//						case (reg_y)
//							ena_R0: mux_sel <= SEL_R0;
//							ena_R1: mux_sel <= SEL_R1;
//							ena_R2: mux_sel <= SEL_R2;
//							ena_R3: mux_sel <= SEL_R3;
//							ena_R4: mux_sel <= SEL_R4;
//							ena_R5: mux_sel <= SEL_R5;
//							ena_R6: mux_sel <= SEL_R6;
//							ena_R7: mux_sel <= SEL_R7;
//						endcase
//					end
//				endcase
//			end
//
//			// Tick 4: Write-Back to Register
//			4'b1000: begin
//				tick_bcd <= 4'b0100;
//				PC <= PC + 2; // Increment PC to next instruction
//
//				case (opcode)
//					MOVI_OP: begin
//						// stay idle again8
//						// i have had enough
//					end
//
//					DISP_OP: begin
//						// stay idle
//					end
//
//					// ADDI: store result in Rx
//					ADDI_OP: begin
//						mux_sel <= SEL_G; // mux_sel G
//						case (reg_x)  // Write-back to Rx
//							ena_R0: R0_enable <= 1'b1;
//							ena_R1: R1_enable <= 1'b1;
//							ena_R2: R2_enable <= 1'b1;
//							ena_R3: R3_enable <= 1'b1;
//							ena_R4: R4_enable <= 1'b1;
//							ena_R5: R5_enable <= 1'b1;
//							ena_R6: R6_enable <= 1'b1;
//							ena_R7: R7_enable <= 1'b1;
//						endcase
//					end
//
//					// SSI: store result in Rx
//					SSI_OP: begin
//						mux_sel <= SEL_G; // mux_sel G
//						case (reg_x)  // Write-back to Rx
//							ena_R0: R0_enable <= 1'b1;
//							ena_R1: R1_enable <= 1'b1;
//							ena_R2: R2_enable <= 1'b1;
//							ena_R3: R3_enable <= 1'b1;
//							ena_R4: R4_enable <= 1'b1;
//							ena_R5: R5_enable <= 1'b1;
//							ena_R6: R6_enable <= 1'b1;
//							ena_R7: R7_enable <= 1'b1;
//						endcase
//					end
//
//					// ADD: Add Ry to Rx and store result in Rx
//					ADD_OP: begin
//						mux_sel <= SEL_G; // mux_sel G
//						case (reg_x)  // Enable the destination register (Rx)
//							ena_R0: R0_enable <= 1'b1;
//							ena_R1: R1_enable <= 1'b1;
//							ena_R2: R2_enable <= 1'b1;
//							ena_R3: R3_enable <= 1'b1;
//							ena_R4: R4_enable <= 1'b1;
//							ena_R5: R5_enable <= 1'b1;
//							ena_R6: R6_enable <= 1'b1;
//							ena_R7: R7_enable <= 1'b1;
//						endcase
//					end
//
//					// SUB: Store result in Rx
//					SUB_OP: begin
//						RG_enable <= 1'b1;
//						mux_sel <= SEL_G; // mux_sel G
//						case (reg_x)  // Enable the destination register (Rx)
//							ena_R0: R0_enable <= 1'b1;
//							ena_R1: R1_enable <= 1'b1;
//							ena_R2: R2_enable <= 1'b1;
//							ena_R3: R3_enable <= 1'b1;
//							ena_R4: R4_enable <= 1'b1;
//							ena_R5: R5_enable <= 1'b1;
//							ena_R6: R6_enable <= 1'b1;
//							ena_R7: R7_enable <= 1'b1;
//						endcase
//					end
//
//					// MUL: Store resule in Rx
//					MUL_OP: begin
//						RG_enable <= 1'b1;
//						mux_sel <= SEL_G; // mux_sel G
//						case (reg_x)  // Enable the destination register (Rx)
//							ena_R0: R0_enable <= 1'b1;
//							ena_R1: R1_enable <= 1'b1;
//							ena_R2: R2_enable <= 1'b1;
//							ena_R3: R3_enable <= 1'b1;
//							ena_R4: R4_enable <= 1'b1;
//							ena_R5: R5_enable <= 1'b1;
//							ena_R6: R6_enable <= 1'b1;
//							ena_R7: R7_enable <= 1'b1;
//						endcase
//					end
//					
//					// BEZ: Branch if equal to zero
//					BEZ_OP: begin
//						if (bus == 0) begin
//							PC <= PC + immediate_reg; // Update PC with branch address
//						end 
//					end
//				endcase
//			end
//		endcase
//	end
//	
//	// Assignments
//	assign alu_op = alu_op_reg; // Use alu_op_reg in ALU instantiation
//	assign bus = mux_out;
//	
//endmodule 