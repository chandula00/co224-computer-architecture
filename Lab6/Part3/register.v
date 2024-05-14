`timescale 1ns/100ps

// Register module definition
module register(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);

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

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, register.REGISTER[0],register.REGISTER[1],register.REGISTER[2],register.REGISTER[3],register.REGISTER[4],register.REGISTER[5],register.REGISTER[6],register.REGISTER[7]);
        
        // finish simulation after some time
        #5000
        $finish;
        
    end
endmodule