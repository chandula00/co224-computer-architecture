`include "mult.v"
`include "shift.v"

// This module performs addition of two 8-bit data inputs
module ADD(DATA1,DATA2,RESULT);
    input [7:0] DATA1, DATA2;
    output [7:0] RESULT;

    // Assigning the sum of DATA1 and DATA2 to RESULT after a delay of 2 time units
    assign #2 RESULT = DATA2 + DATA1;
endmodule


// This module forwards the 8-bit data input to the output without any operation
module FORWARD(DATA2,RESULT);
    input [7:0] DATA2;
    output [7:0] RESULT;
    
    // Assigning the input data to the output after a delay of 1 time unit
    assign #1 RESULT = DATA2;
endmodule


// This module performs bitwise AND operation on two 8-bit data inputs
module AND(DATA1,DATA2,RESULT);
    input [7:0] DATA1, DATA2;
    output [7:0] RESULT;

    //assigning the result to output after a delay of 1 time unit
    assign #1 RESULT = DATA2 & DATA1;
endmodule


// This module performs bitwise OR operation on two 8-bit data inputs
module OR(DATA1,DATA2,RESULT);
    input [7:0] DATA1, DATA2;
    output [7:0] RESULT;

    //assigning the result to output after a delay of 1 time unit
    assign #1 RESULT = DATA2 | DATA1;
endmodule




// ALU module definition
module ALU(DATA1,DATA2,SELECT,RESULT,ZERO);

    // Declaring the input and output
    input [7:0] DATA1, DATA2;
    input [2:0] SELECT;
    reg [7:0] RESULT;
    output reg ZERO;
    output [7:0] RESULT;
    wire [7:0] OUTPUT_add, OUTPUT_forward, OUTPUT_or, OUTPUT_and, OUTPUT_logShift, OUTPUT_ASR, OUTPUT_ROR, OUTPUT_mult;

    // Instantiating the FORWARD, ADD, AND, and OR modules with necessary inputs and outputs
    FORWARD forward_(DATA2, OUTPUT_forward);
    ADD add_(DATA1, DATA2, OUTPUT_add);
    AND and_(DATA1, DATA2, OUTPUT_and);
    OR or_(DATA1, DATA2, OUTPUT_or);
    LOG_SHIFT s_l_(DATA1, DATA2, OUTPUT_logShift);
    ARITH_RIGHT_SHIFT sra_(DATA1, DATA2, OUTPUT_ASR); 
    ROT_RIGHT ror_(DATA1, DATA2, OUTPUT_ROR); 
    MULT mult_(DATA1, DATA2, OUTPUT_mult);

    // Triggering when any of the input signals or any of the output wires changes
    always @ (OUTPUT_forward, OUTPUT_add, OUTPUT_and, OUTPUT_or,OUTPUT_logShift, OUTPUT_ASR, OUTPUT_ROR, OUTPUT_mult, SELECT)
	begin
		case (SELECT) // SELECT input to select which module output to assign to the RESULT register		

			3'b000 :	RESULT = OUTPUT_forward;    // if SELECT is 000, forward the DATA2 input to the RESULT
			3'b001 :	begin 
                            RESULT = OUTPUT_add;    // if SELECT is 001, assign the output of the adder to the RESULT
                            // If RESULT = 0, then ZERO => 1
                            ZERO = ~(RESULT[0] | RESULT[1] | RESULT[2] | RESULT[3] | RESULT[4] | RESULT[5] | RESULT[6] | RESULT[7]);
                        end
			3'b010 :	RESULT = OUTPUT_and;        // if SELECT is 010, assign the output of the bitwise AND to the RESULT
			3'b011 :	RESULT = OUTPUT_or;         // if SELECT is 011, assign the output of the bitwise OR to the RESULT		
			3'b100 :	RESULT = OUTPUT_logShift;   // if SELECT is 100, assign the output of the logical SHIFTER to the RESULT		
			3'b101 :	RESULT = OUTPUT_ASR;        // if SELECT is 101, assign the output of the arithmatic right SHIFTER to the RESULT		
			3'b110 :	RESULT = OUTPUT_ROR;        // if SELECT is 110, assign the output of the right ROTATOR to the RESULT		
			3'b111 :	RESULT = OUTPUT_mult;       // if SELECT is 111, assign the output of MULTIPLIER to the RESULT

		endcase
	end
    
endmodule