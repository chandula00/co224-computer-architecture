// Lab 5 - Part 4 
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

module branch(PC, OFFSET, TARGET);
	input [31:0] PC;
	input signed [7:0] OFFSET;
	output [31:0] TARGET;
	
	// wire [21:0] signBits;
	assign #2 TARGET = PC + OFFSET*4;
	
endmodule

module flowControl(BRANCH_JUMP,ZERO,OUT);
	input[1:0] BRANCH_JUMP;
	input ZERO;
	output OUT;

	assign OUT = BRANCH_JUMP[0] ^ (BRANCH_JUMP[1] & ZERO);
endmodule

module flowControlMux(INPUT1,INPUT2,SELECT,OUTPUT);
	input [31:0] INPUT1,INPUT2;
    input SELECT;
    output reg [31:0] OUTPUT;

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

module PCupdate(PC,PCout);
	input [31:0] PC;
	output [31:0] PCout;

	assign #1 PCout = PC + 4;
endmodule

// CPU module definition
// Contains all the necessary components of the CPU
module cpu(PC, INSTRUCTION, CLK, RESET, READ, WRITE, ADDRESS, WRITEDATA, READDATA, BUSYWAIT);

    // Declaring the input and output
    input [31:0] INSTRUCTION;
	input [7:0] READDATA;
    input CLK, RESET, BUSYWAIT;
    
	output reg [31:0] PC;
	output [7:0] ADDRESS, WRITEDATA;
	output reg READ, WRITE;
    
    // 8-bit wire for OP-Code
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

	// PC+4 value and PC value to be updated stored inside CPU
	wire [31:0] nextPC;
	wire [31:0] PCout;

	// Connections for Jump/Branch Adder
	wire [31:0] TARGET;
	wire [7:0] OFFSET;
	
	// Connections for flow control combinational unit
	reg [1:0] BRANCH_JUMP;

	// Connections for flow control MUX
	wire SELECT_flow;

	//Connections for flow control MUX
	wire flowSelect;
	
	//Connections to Data memory
	assign ADDRESS = ALURESULT;
	assign WRITEDATA = REGOUT1;
	
	//Connections for data memory MUX
	reg dataSelect;
	wire [7:0] REGIN;

    // Instantiating the register, ALU, twosCompliment, and mux modules with necessary inputs and outputs
    register Reg(REGIN, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, (WRITEENABLE & (!BUSYWAIT)), CLK, RESET);
    twosCompliment TwosCompliment(DATA2,NegatedDATA);
    mux NegationMux(DATA2, NegatedDATA, SELECT_neg, ResultDATA);
    mux ImmediateMUX(REGOUT2, IMMEDIATE, SELECT_imm, DATA2);
    ALU Alu(REGOUT1, ResultDATA, ALUOP, ALURESULT, ZERO);
	PCupdate PCUpdate(PC,PCout);
	branch Branch(PCout,OFFSET,TARGET);
	flowControl FlowControl(BRANCH_JUMP,ZERO,SELECT_flow);
	flowControlMux FlowControlMux(PCout,TARGET,SELECT_flow,nextPC);
	mux DataMemMux(ALURESULT, READDATA, dataSelect, REGIN);

    // Triggering with positive edge of clock pulse
    always @ ( posedge CLK)
	begin
		if (RESET == 1'b1) #1 PC = 0;	// If RESET signal is 1,Set PC to zero after a delay of #1
		else if (BUSYWAIT == 1'b1);		// If BUSYWAIT signal is HIGH, do nothing (Keep same PC value)	
		else #1 PC = nextPC;    		// Else, update PC with new PC value		
	end

	//Clearing READ/WRITE controls for Data Memory when BUSYWAIT is de-asserted
	always @ (BUSYWAIT)
	begin
		if (BUSYWAIT == 1'b0)
		begin
			READ = 0;
			WRITE = 0;
		end
	end

    // Mapping relevant parts of INSTRUCTION to corresponding units
    /*+--------------------------------------------------------------+
	  |    OP-CODE    |     RD/IMM    |       RT      |     RS/IMM   |
	  |    [31:24]    |    [23:16]    |     [15:8]    |     [7:0]    |
	  +--------------------------------------------------------------+
	  |    OPCODE     |    WRITEREG   |    READREG1   |    READREG2  |
	  |               |     OFFSET    |               |   IMMEDIATE  |
	  +--------------------------------------------------------------+*/
    assign OPCODE = INSTRUCTION[31:24];
    assign WRITEREG = INSTRUCTION[23:16];
	assign OFFSET = INSTRUCTION[23:16];
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
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
		
			//mov instruction
			8'b00000001:	begin
								ALUOP = 3'b000;			//Set ALU to FORWARD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
			
			//add instruction
			8'b00000010:	begin
								ALUOP = 3'b001;			//Set ALU to ADD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end	
		
			//sub instruction
			8'b00000011:	begin
								ALUOP = 3'b001;			//Set ALU to ADD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b1;		//Set MUX to select negetive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end

			//and instruction
			8'b00000100:	begin
								ALUOP = 3'b010;			//Set ALU to AND
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
							
			//or operation
			8'b00000101:	begin
								ALUOP = 3'b011;			//Set ALU to OR
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
			
			//j instruction
			8'b00000110:	begin
								ALUOP = 3'b000;			//This is Not valid
								SELECT_imm = 1'b0;		//This is Not valid
								SELECT_neg = 1'b0;		//This is Not valid
								BRANCH_JUMP = 2'b01;	//Set flow control signal to j
								WRITEENABLE = 1'b0;		//Disable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
			
			//beq instruction
			8'b00000111:	begin
								ALUOP = 3'b001;			//Set ALU to ADD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b1;		//Set MUX to select negative value
								BRANCH_JUMP = 2'b10;	//Set flow control signal to beq
								WRITEENABLE = 1'b0;		//Disable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end

			//lwd instruction
			8'b00001000:	begin
								ALUOP = 3'b000;			//Set ALU to forward
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select negative value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b1;			//Set READ control signal to HIGH
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b1;		//Set Data Memory MUX to Data memory input
							end
							
			//lwi instruction
			8'b00001001:	begin
								ALUOP = 3'b000;			//Set ALU to forward
								SELECT_imm = 1'b1;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select negative value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b1;			//Set READ control signal to HIGH
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b1;		//Set Data Memory MUX to Data memory input
							end
			
			//swd instruction
			8'b00001010:	begin
								ALUOP = 3'b000;			//Set ALU to forward
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select negative value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b0;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b1;			//Set WRITE control signal to HIGH
							end
							
			//swi instruction
			8'b00001011:	begin
								ALUOP = 3'b000;			//Set ALU to forward
								SELECT_imm = 1'b1;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select negative value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal
								WRITEENABLE = 1'b0;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b1;			//Set WRITE control signal to HIGH
							end


			//bne instruction
			8'b00001100:	begin
								ALUOP = 3'b001;			//Set ALU to ADD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b1;		//Set MUX to select negative value
								BRANCH_JUMP = 2'b11;	//Set flow control signal to bne
								WRITEENABLE = 1'b0;		//Disable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
			
			//mult instruction
			8'b00001101:	begin
								ALUOP = 3'b111;			//Set ALU to ADD
								SELECT_imm = 1'b0;		//Set MUX to select register input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal flow
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end

			//sll instruction
			8'b00001110:	begin
								ALUOP = 3'b100;			//Set ALU to LEFT_SHIFT
								SELECT_imm = 1'b1;		//Set MUX to select immediate input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal flow
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
			
			//srl instruction
			8'b00001111:	begin
								ALUOP = 3'b100;			//Set ALU to LEFT_SHIFT
								SELECT_imm = 1'b1;		//Set MUX to select immediate input
								SELECT_neg = 1'b1;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal flow
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
			
			//sra instruction
			8'b00010000:	begin
								ALUOP = 3'b101;			//Set ALU to LEFT_SHIFT
								SELECT_imm = 1'b1;		//Set MUX to select immediate input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal flow
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
			
			//ror instruction
			8'b00010001:	begin
								ALUOP = 3'b110;			//Set ALU to LEFT_SHIFT
								SELECT_imm = 1'b1;		//Set MUX to select immediate input
								SELECT_neg = 1'b0;		//Set MUX to select positive value
								BRANCH_JUMP = 2'b00;	//Set flow control signal to normal flow
								WRITEENABLE = 1'b1;		//Enable writing to register
								READ = 1'b0;			//Set READ control signal to zero
								WRITE = 1'b0;			//Set WRITE control signal to zero
								dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
							end
		endcase	
	end	
endmodule