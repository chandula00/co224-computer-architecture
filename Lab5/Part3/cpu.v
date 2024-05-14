// Lab 5 - Part 3 
// Group Number : 09

// Importing pre implemented modules
`include "alu.v"
`include "register.v"


// This module returns the 2's complement of the input
module twosCompliment(REGOUT2,RESULT);
    input [7:0] REGOUT2;
    output [7:0] RESULT;

    // Assigning 2's complement of input to output after a delay of #1
    assign #1 RESULT = ~REGOUT2 + 1;
endmodule


// A general MUX module for NegationMux and ImmediateMUX
module mux(INPUT1,INPUT2,SELECT,OUTPUT);
    input [7:0] INPUT1,INPUT2;
    input SELECT;
    output reg [7:0] OUTPUT;

    // When update atleast one of INPUT1, INPUT2 or SELECT
    always @ (INPUT1, INPUT2, SELECT)
	begin
		if (SELECT == 1'b1)		// If SELECT is 1, switch to 2nd input
		begin
			OUTPUT = INPUT2;
		end
		else					// If SELECT is 0, switch to 1st input
		begin
			OUTPUT = INPUT1;
		end
	end
endmodule


// CPU module definition
// Contains all the necessary components of the CPU
module cpu(PC, INSTRUCTION, CLK, RESET);

    // Declaring the input and output
    input [31:0] INSTRUCTION;
    input CLK, RESET;
    output reg [31:0] PC;
    
    // 8-bit register to store OP-Code
    wire [7:0] OPCODE;

    // Connections pre defined "register" module
    wire [2:0] READREG1, READREG2, WRITEREG;
	wire [7:0] REGOUT1, REGOUT2;
	reg WRITEENABLE;

    // Connections pre defined "ALU" module
    wire [7:0] DATA1, DATA2, ALURESULT;
	reg [2:0] ALUOP;

    // Connections for negation value select MUX
    wire [7:0] NegatedDATA;
	wire [7:0] ResultDATA;
	reg SELECT_neg;

    // Connections for immediate value select MUX
    wire [7:0] IMMEDIATE;
    reg SELECT_imm;

    // Instantiating the register, ALU, twosCompliment, and mux modules with necessary inputs and outputs
    register Reg(ALURESULT, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    ALU Alu(REGOUT1, DATA2, ALUOP, ALURESULT);
    twosCompliment TwosCompliment(REGOUT2,NegatedDATA);
    mux NegationMux(REGOUT2, NegatedDATA, SELECT_neg, ResultDATA);
    mux ImmediateMUX(ResultDATA, IMMEDIATE, SELECT_imm, DATA2);

    // Triggering with positive edge of clock pulse
    always @ ( posedge CLK)
	begin
		if (RESET == 1'b1)      // If RESET signal is 1
		begin
			#1 PC = 0;          // Set PC to zero after a delay of #1		
		end
		else #1 PC = PC + 4;    // Update PC with new PC value		
	end

    // Mapping relevant parts of INSTRUCTION to corresponding units
    /*+--------------------------------------------------------------+
	  |    OP-CODE    |      RD       |       RT      |     RS/IMM   |
	  |    [31:24]    |    [23:16]    |     [15:8]    |      [7:0]   |
	  +--------------------------------------------------------------+
	  |    OPCODE     |    WRITEREG   |    READREG1   |    READREG2  |
	  |               |               |               |   IMMEDIATE  |
	  +--------------------------------------------------------------+*/
    assign OPCODE = INSTRUCTION[31:24];
    assign WRITEREG = INSTRUCTION[23:16];
    assign READREG1 = INSTRUCTION[15:8];
	assign IMMEDIATE = INSTRUCTION[7:0];
	assign READREG2 = INSTRUCTION[7:0];

    // With updating INSTRUCTIONS
    always @ (INSTRUCTION)
	begin		
		
		#1
        case (OPCODE) // OPCODE to select which instruction should be executed
        	//loadi instruction
			8'b00000000:	begin
								ALUOP = 3'b000;			//Set ALU to FORWARD
								SELECT_imm = 1'b1;		//Set MUX to select immediate value
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								WRITEENABLE = 1'b1;		//Enable writing to register
							end
		
			//mov instruction
			8'b00000001:	begin
								ALUOP = 3'b000;			//Set ALU to FORWARD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								WRITEENABLE = 1'b1;		//Enable writing to register
							end
			
			//add instruction
			8'b00000010:	begin
								ALUOP = 3'b001;			//Set ALU to ADD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								WRITEENABLE = 1'b1;		//Enable writing to register
							end	
		
			//sub instruction
			8'b00000011:	begin
								ALUOP = 3'b001;			//Set ALU to ADD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b1;		//Set MUX to select negetive value
								WRITEENABLE = 1'b1;		//Enable writing to register
							end

			//and instruction
			8'b00000100:	begin
								ALUOP = 3'b010;			//Set ALU to AND
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								WRITEENABLE = 1'b1;		//Enable writing to register
							end
							
			//or operation
			8'b00000101:	begin
								ALUOP = 3'b011;			//Set ALU to OR
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								WRITEENABLE = 1'b1;		//Enable writing to register
							end
		endcase	
	end	
endmodule

