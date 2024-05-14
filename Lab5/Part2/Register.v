// Top-level module for testing the Register
module testbed;

    // Inputs and outputs
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;                              // 8-bit data outputs

    // Instantiate the Register module and connecting its ports to the testbed signals
    Register reg_t(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);


    // Set initial values for inputs and address signals, and test register file operations
    initial
    begin
        CLK = 1'b1;
        
        // Dump waveform data to a VCD file, and monitor the output signals
        $dumpfile("wavedata_Register.vcd");
		$dumpvars(0, testbed);
		$monitor("TIME = %g  OUT1 = %d, OUT2 = %d", $time, REGOUT1, REGOUT2);
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #4
        RESET = 1'b1;
        READREG1 = 3'd0;
        READREG2 = 3'd4;
        
        #6
        RESET = 1'b0;
        
        #2
        WRITEREG = 3'd2;
        WRITEDATA = 8'd95;
        WRITEENABLE = 1'b1;
        
        #7
        WRITEENABLE = 1'b0;
        
        #1
        READREG1 = 3'd2;
        
        #7
        WRITEREG = 3'd1;
        WRITEDATA = 8'd28;
        WRITEENABLE = 1'b1;
        READREG1 = 3'd1;
        
        #8
        WRITEENABLE = 1'b0;
        
        #8
        WRITEREG = 3'd4;
        WRITEDATA = 8'd6;
        WRITEENABLE = 1'b1;
        
        #8
        WRITEDATA = 8'd15;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = -3'd1;
        WRITEDATA = 8'd50;
        WRITEENABLE = 1'b1;
        
        #5
        WRITEENABLE = 1'b0;
        
        #10
        $finish;
    end

    // Toggle the clock signal every 2 time units
    always #4 CLK = ~CLK;

    // Dump waveform data to a VCD file, and monitor the output signals

endmodule


// Register module definition
module Register(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);

    // Inputs and outputs
    input [7:0] IN;                                     // 8-bit data input
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;    // 3-bit register address inputs

    input WRITE, CLK, RESET;                            // Write enable, clock, and reset signals

    output [7:0] OUT1, OUT2;                            // 8-bit data outputs

    reg [7:0] REGISTER[7:0];                            // 8 registers, each containing an 8-bit value

    assign #2 OUT1 = REGISTER[OUT1ADDRESS];             // Assign the value at the address specified by OUT1ADDRESS to OUT1 after a delay of 2 time units
    assign #2 OUT2 = REGISTER[OUT2ADDRESS];             // Assign the value at the address specified by OUT2ADDRESS to OUT2 after a delay of 2 time units

    // Integer to be used for the for loop
    integer i;

    always @ (posedge CLK)
	begin
        // If RESET signal is HIGH, registers must be cleared
		if (RESET == 1'b1)		
		begin
            // For loop to iterate over all 8 register addresses after 1 time unit delay
			for (i = 0; i < 8; i = i + 1)			
			begin
				REGISTER[i] <= #1 0;		// Setting each element of the REGISTER array to 0
			end
			
		end
        // If the RESET signal is LOW, write to the registers if WRITE signal is HIGH
		else if (WRITE == 1'b1)			
		begin
            //Assigns the input value IN to relevant register address after a delay of 1
			REGISTER[INADDRESS] <= #1 IN;		
			
		end
		
	end
endmodule