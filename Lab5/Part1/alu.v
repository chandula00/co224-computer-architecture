// This module is the top-level module for testing the ALU module
module testbed;

    // Declaring the input and output signals for the testbed
    reg [7:0] DATA1_test, DATA2_test;
    reg [2:0] SELECT_test;
    wire [7:0] RESULT_test;

    // Instantiating the ALU module and connecting its ports to the testbed signals
    ALU alu_t(DATA1_test,DATA2_test,SELECT_test,RESULT_test);

    // Defining the initial block for simulation
    initial
    begin
        // Printing the values of the signals using $monitor system task
        $monitor("TIME = %g  DATA1 = %b, DATA2 = %b, SELECT = %b, RESULT = %b", $time, DATA1_test, DATA2_test, SELECT_test, RESULT_test);
        
        // Creating a VCD file for waveform viewing using $dumpfile system task
        $dumpfile("wavedata_ALU.vcd");
        
        // Adding signals to be dumped to the VCD file using $dumpvars system task
        $dumpvars(0, testbed);

        // Set initial values for inputs and test ALU operations
        DATA1_test = 1;
        DATA2_test = 2;
        SELECT_test = 0;

        #6
        DATA1_test = 3;
        DATA2_test = 4;
        SELECT_test = 1;

        #7
        DATA1_test = 4;
        DATA2_test = 5;
        SELECT_test = 2;

        #6
        DATA1_test = 6;
        DATA2_test = 7;
        SELECT_test = 3;

        #6
        $finish;    // Finishing the simulation
    end
 endmodule


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
module ALU(DATA1,DATA2,SELECT,RESULT);

    // Declaring the input and output
    input [7:0] DATA1, DATA2;
    input [2:0] SELECT;
    reg [7:0] RESULT;
    output [7:0] RESULT;
    wire [7:0] OUTPUT_add, OUTPUT_forward, OUTPUT_or, OUTPUT_and;

    // Instantiating the FORWARD, ADD, AND, and OR modules with necessary inputs and outputs
    FORWARD forward_(DATA2, OUTPUT_forward);
    ADD add_(DATA1, DATA2, OUTPUT_add);
    AND and_(DATA1, DATA2, OUTPUT_and);
    OR or_(DATA1, DATA2, OUTPUT_or);

    // Triggering when any of the input signals or any of the output wires changes
    always @ (OUTPUT_forward, OUTPUT_add, OUTPUT_and, OUTPUT_or, SELECT)
	begin
		case (SELECT) // SELECT input to select which module output to assign to the RESULT register		

			3'b000 :	RESULT = OUTPUT_forward;  // if SELECT is 000, forward the DATA2 input to the RESULT
			3'b001 :	RESULT = OUTPUT_add;      // if SELECT is 001, assign the output of the adder to the RESULT
			3'b010 :	RESULT = OUTPUT_and;      // if SELECT is 010, assign the output of the bitwise AND to the RESULT
			3'b011 :	RESULT = OUTPUT_or;       // if SELECT is 011, assign the output of the bitwise OR to the RESULT		
			
		endcase
	end
    
endmodule