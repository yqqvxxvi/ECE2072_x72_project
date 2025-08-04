Since this is a school project, I couldn't share my code to prevent breaching of academic integrity ;D

**x72 Processor – FPGA-Based 16-bit CPU**


A custom 16-bit CPU implemented on the Intel DE10-Lite FPGA as part of the ECE2072 Digital Systems Project at Monash University.
The project demonstrates modular CPU design, ALU operations, FSM-based control, and hardware verification using simulation and live FPGA testing.

**📖 Project Overview**
The x72 processor is a simple RISC-like 16-bit CPU capable of performing:

- Arithmetic and logical operations via a custom ALU

- Immediate and two-register instructions

- Signed shift operations (SSI)

- Multiplication and register-to-display output (DISP)

- Program execution using a 4-tick FSM control sequence

- The processor is fully modular, built from reusable components:

- ALU – Addition, subtraction, signed shift, multiplication

- Registers – Parameterized for flexible width

- Sign Extender – 9-bit to 16-bit extension

- Multiplexer – Routes data to the system bus

- Tick FSM – 4-state control for instruction sequencing
**
✨ Key Features**
✅ Modular 16-bit CPU architecture

✅ Supports ADDI, SUB, MOVI, SSI, DISP, MULT instructions

✅ Register-to-display output using 7-segment displays

✅ Fully testbenched in ModelSim with waveform verification

✅ Timing & resource analysis to identify critical paths (ALU at 86.39 MHz)

✅ Hardware-verified on DE10-Lite FPGA

🖥 Hardware Setup
FPGA Board: Intel DE10-Lite

Software: Intel Quartus Prime & ModelSim

Instruction Execution:

Load 9-bit encoded instruction via SW[8:0]

Use KEY[0] for reset and KEY[1] for manual clocking

Observe:

LEDR for bus output

HEX5 for FSM tick

HEX0–HEX4 for register display (DISP instruction)

**🔬 Testing Methodology**
Component Testbenches:
Verified each module (ALU, FSM, Registers, MUX, Sign Extender) independently with boundary and overflow tests.

Processor Testbench:
Manual clock control ensured precise verification of 4-tick instruction execution, preventing timing hazards from the ALU.

Hardware Verification:
Live demo on DE10-Lite FPGA for instructions:

ADDI, SUB → Arithmetic correctness

SSI → Signed shifting

DISP → Register-to-7-segment output

**📊 Resource & Timing Analysis**
Component	Logic Elements	Max Freq (MHz)
Sign Extender	25	1094.09
Tick FSM	12	605.69
ALU	276	86.39
Multiplexer	180	225.48
Register	51	562.75

-> ALU is the critical path. Optimizations focused on pipeline stability and manual clocking for testing.

**🚀 Future Work**
Implement instruction memory & branching (Task 4)

Introduce pipeline stages for higher throughput

Optimize ALU to reduce critical path delay

**👨‍💻 Authors**
You Qing Liew
