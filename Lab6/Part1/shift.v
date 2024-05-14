module mux_bit(OUTPUT_m, INPUT1,INPUT2,SELECT);
	// Declaration of input and output ports
    input SELECT, INPUT1,INPUT2;
    output OUTPUT_m ;
    wire orIn1 ,orIn2;

	// MUX implementation
    // Output = {INPUT1 & (!SELECT) | INPUT2 & SELECT}
    assign orIn1 = INPUT1 & (!SELECT);
    assign orIn2 = INPUT2 & SELECT;
    assign OUTPUT_m = orIn1 | orIn2;
endmodule

module LSMUX(INPUT1,INPUT2,SELECT,OUTPUT);
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


module LEFT_SHIFT(DATA1, DATA2, OUTPUT);

	// Declaration of input and output ports
    input [7:0] DATA1, DATA2;
    output  [7:0] OUTPUT;
    
	// Intermediate connections between MUX layers 
    wire [7:0] layer1OUT,layer2OUT,layer3OUT;
    wire s[7:0];


	// MUX Layer 1
    mux_bit layer10(layer1OUT[0],DATA1[0],1'b0,DATA2[0]);
    mux_bit layer11(layer1OUT[1],DATA1[1],DATA1[0],DATA2[0]);
    mux_bit layer12(layer1OUT[2],DATA1[2],DATA1[1],DATA2[0]);
    mux_bit layer13(layer1OUT[3],DATA1[3],DATA1[2],DATA2[0]);
    mux_bit layer14(layer1OUT[4],DATA1[4],DATA1[3],DATA2[0]);
    mux_bit layer15(layer1OUT[5],DATA1[5],DATA1[4],DATA2[0]);
    mux_bit layer16(layer1OUT[6],DATA1[6],DATA1[5],DATA2[0]);
    mux_bit layer17(layer1OUT[7],DATA1[7],DATA1[6],DATA2[0]);
  
	// MUX Layer 2
    mux_bit layer20(layer2OUT[0],layer1OUT[0],1'b0,DATA2[1]);    
    mux_bit layer21(layer2OUT[1],layer1OUT[1],1'b0,DATA2[1]);
    mux_bit layer22(layer2OUT[2],layer1OUT[2],layer1OUT[0],DATA2[1]);
    mux_bit layer23(layer2OUT[3],layer1OUT[3],layer1OUT[1],DATA2[1]);
    mux_bit layer24(layer2OUT[4],layer1OUT[4],layer1OUT[2],DATA2[1]);
    mux_bit layer25(layer2OUT[5],layer1OUT[5],layer1OUT[3],DATA2[1]);
    mux_bit layer26(layer2OUT[6],layer1OUT[6],layer1OUT[4],DATA2[1]);
    mux_bit layer27(layer2OUT[7],layer1OUT[7],layer1OUT[5],DATA2[1]);
  
	// MUX Layer 3
    mux_bit layer30(layer3OUT[0],layer2OUT[0],1'b0,DATA2[2]);    
    mux_bit layer31(layer3OUT[1],layer2OUT[1],1'b0,DATA2[2]);
    mux_bit layer32(layer3OUT[2],layer2OUT[2],1'b0,DATA2[2]);
    mux_bit layer33(layer3OUT[3],layer2OUT[3],1'b0,DATA2[2]);
    mux_bit layer34(layer3OUT[4],layer2OUT[4],layer2OUT[0],DATA2[2]);
    mux_bit layer35(layer3OUT[5],layer2OUT[5],layer2OUT[1],DATA2[2]);
    mux_bit layer36(layer3OUT[6],layer2OUT[6],layer2OUT[2],DATA2[2]);
    mux_bit layer37(layer3OUT[7],layer2OUT[7],layer2OUT[3],DATA2[2]);

	// Assigning final output after 2 time unit delay
	// If shift amount is 8, then output >>>> 8'd0
    assign #2 OUTPUT= (DATA2==8'd8)? 8'd0:layer3OUT;	
endmodule

module RIGHT_SHIFT(DATA1, DATA02, OUTPUT);

    // Declaration of input and output ports
    input [7:0] DATA1, DATA02;
    output  [7:0] OUTPUT;
    
    // Intermediate connections between MUX layers 
    wire [7:0] layer1OUT, layer2OUT, layer3OUT, DATA2;
    assign #1 DATA2 = ~DATA02 + 1;
  
    // MUX Layer 1
    mux_bit layer10(layer1OUT[0], DATA1[0], DATA1[1], DATA2[0]);
    mux_bit layer11(layer1OUT[1], DATA1[1], DATA1[2], DATA2[0]);
    mux_bit layer12(layer1OUT[2], DATA1[2], DATA1[3], DATA2[0]);
    mux_bit layer13(layer1OUT[3], DATA1[3], DATA1[4], DATA2[0]);
    mux_bit layer14(layer1OUT[4], DATA1[4], DATA1[5], DATA2[0]);
    mux_bit layer15(layer1OUT[5], DATA1[5], DATA1[6], DATA2[0]);
    mux_bit layer16(layer1OUT[6], DATA1[6], DATA1[7], DATA2[0]);
    mux_bit layer17(layer1OUT[7], DATA1[7], 1'b0, DATA2[0]);
  
    // MUX Layer 2
    mux_bit layer20(layer2OUT[0], layer1OUT[0], layer1OUT[2], DATA2[1]);    
    mux_bit layer21(layer2OUT[1], layer1OUT[1], layer1OUT[3], DATA2[1]);
    mux_bit layer22(layer2OUT[2], layer1OUT[2], layer1OUT[4], DATA2[1]);
    mux_bit layer23(layer2OUT[3], layer1OUT[3], layer1OUT[5], DATA2[1]);
    mux_bit layer24(layer2OUT[4], layer1OUT[4], layer1OUT[6], DATA2[1]);
    mux_bit layer25(layer2OUT[5], layer1OUT[5], layer1OUT[7], DATA2[1]);
    mux_bit layer26(layer2OUT[6], layer1OUT[6], 1'b0, DATA2[1]);
    mux_bit layer27(layer2OUT[7], layer1OUT[7], 1'b0, DATA2[1]);
  
    // MUX Layer 3
    mux_bit layer30(layer3OUT[0], layer2OUT[0], layer2OUT[4], DATA2[2]);    
    mux_bit layer31(layer3OUT[1], layer2OUT[1], layer2OUT[5], DATA2[2]);
    mux_bit layer32(layer3OUT[2], layer2OUT[2], layer2OUT[6], DATA2[2]);
    mux_bit layer33(layer3OUT[3], layer2OUT[3], layer2OUT[7], DATA2[2]);
    mux_bit layer34(layer3OUT[4], layer2OUT[4], 1'b0, DATA2[2]);
    mux_bit layer35(layer3OUT[5], layer2OUT[5], 1'b0, DATA2[2]);
    mux_bit layer36(layer3OUT[6], layer2OUT[6], 1'b0, DATA2[2]);
    mux_bit layer37(layer3OUT[7], layer2OUT[7], 1'b0, DATA2[2]);

    // Assigning final output after 2 time unit delay
    // If shift amount is 8, then output >>>> 8'd0
    assign #2 OUTPUT = (DATA2 == 8'd8) ? 8'd0 : layer3OUT;  
endmodule

module LOG_SHIFT(DATA1, DATA2, OUTPUT);

    // Declaration of input and output ports
    input [7:0] DATA1, DATA2;
    output  [7:0] OUTPUT;

    // Intermediate connections
    wire [7:0] OUTPUT_leftShift, OUTPUT_rightShift;

    // Instantiating the modules for logical shift
    LEFT_SHIFT sll_(DATA1, DATA2, OUTPUT_leftShift);
    RIGHT_SHIFT srl(DATA1, DATA2, OUTPUT_rightShift);
    LSMUX lsmux_(OUTPUT_leftShift,OUTPUT_rightShift, DATA2[7], OUTPUT); 
endmodule


module ARITH_RIGHT_SHIFT(DATA1, DATA2, OUTPUT);

    // Declaration of input and output ports
    input [7:0] DATA1, DATA2;
    output  [7:0] OUTPUT;
    
    // Intermediate connections between MUX layers 
    wire [7:0] layer1OUT, layer2OUT, layer3OUT;
    wire s[7:0];
  
    // MUX Layer 1
    mux_bit layer10(layer1OUT[0], DATA1[0], DATA1[1], DATA2[0]);
    mux_bit layer11(layer1OUT[1], DATA1[1], DATA1[2], DATA2[0]);
    mux_bit layer12(layer1OUT[2], DATA1[2], DATA1[3], DATA2[0]);
    mux_bit layer13(layer1OUT[3], DATA1[3], DATA1[4], DATA2[0]);
    mux_bit layer14(layer1OUT[4], DATA1[4], DATA1[5], DATA2[0]);
    mux_bit layer15(layer1OUT[5], DATA1[5], DATA1[6], DATA2[0]);
    mux_bit layer16(layer1OUT[6], DATA1[6], DATA1[7], DATA2[0]);
    mux_bit layer17(layer1OUT[7], DATA1[7], DATA1[7], DATA2[0]);
  
    // MUX Layer 2
    mux_bit layer20(layer2OUT[0], layer1OUT[0], layer1OUT[2], DATA2[1]);    
    mux_bit layer21(layer2OUT[1], layer1OUT[1], layer1OUT[3], DATA2[1]);
    mux_bit layer22(layer2OUT[2], layer1OUT[2], layer1OUT[4], DATA2[1]);
    mux_bit layer23(layer2OUT[3], layer1OUT[3], layer1OUT[5], DATA2[1]);
    mux_bit layer24(layer2OUT[4], layer1OUT[4], layer1OUT[6], DATA2[1]);
    mux_bit layer25(layer2OUT[5], layer1OUT[5], layer1OUT[7], DATA2[1]);
    mux_bit layer26(layer2OUT[6], layer1OUT[6], layer1OUT[7], DATA2[1]);
    mux_bit layer27(layer2OUT[7], layer1OUT[7], layer1OUT[7], DATA2[1]);
  
    // MUX Layer 3
    mux_bit layer30(layer3OUT[0], layer2OUT[0], layer2OUT[4], DATA2[2]);    
    mux_bit layer31(layer3OUT[1], layer2OUT[1], layer2OUT[5], DATA2[2]);
    mux_bit layer32(layer3OUT[2], layer2OUT[2], layer2OUT[6], DATA2[2]);
    mux_bit layer33(layer3OUT[3], layer2OUT[3], layer2OUT[7], DATA2[2]);
    mux_bit layer34(layer3OUT[4], layer2OUT[4], layer2OUT[7], DATA2[2]);
    mux_bit layer35(layer3OUT[5], layer2OUT[5], layer2OUT[7], DATA2[2]);
    mux_bit layer36(layer3OUT[6], layer2OUT[6], layer2OUT[7], DATA2[2]);
    mux_bit layer37(layer3OUT[7], layer2OUT[7], layer2OUT[7], DATA2[2]);

    // Assigning final output after 2 time unit delay
    // If shift amount is 8, then output >>>> 8'd0
    assign #2 OUTPUT = layer3OUT;  
endmodule


module ROT_RIGHT(DATA1, DATA2, OUTPUT);

    // Declaration of input and output ports
    input [7:0] DATA1, DATA2;
    output  [7:0] OUTPUT;
    
    // Intermediate connections between MUX layers 
    wire [7:0] layer1OUT, layer2OUT, layer3OUT;
    wire s[7:0];
  
    // MUX Layer 1
    mux_bit layer10(layer1OUT[0], DATA1[0], DATA1[1], DATA2[0]);
    mux_bit layer11(layer1OUT[1], DATA1[1], DATA1[2], DATA2[0]);
    mux_bit layer12(layer1OUT[2], DATA1[2], DATA1[3], DATA2[0]);
    mux_bit layer13(layer1OUT[3], DATA1[3], DATA1[4], DATA2[0]);
    mux_bit layer14(layer1OUT[4], DATA1[4], DATA1[5], DATA2[0]);
    mux_bit layer15(layer1OUT[5], DATA1[5], DATA1[6], DATA2[0]);
    mux_bit layer16(layer1OUT[6], DATA1[6], DATA1[7], DATA2[0]);
    mux_bit layer17(layer1OUT[7], DATA1[7], DATA1[0], DATA2[0]);
  
    // MUX Layer 2
    mux_bit layer20(layer2OUT[0], layer1OUT[0], layer1OUT[2], DATA2[1]);    
    mux_bit layer21(layer2OUT[1], layer1OUT[1], layer1OUT[3], DATA2[1]);
    mux_bit layer22(layer2OUT[2], layer1OUT[2], layer1OUT[4], DATA2[1]);
    mux_bit layer23(layer2OUT[3], layer1OUT[3], layer1OUT[5], DATA2[1]);
    mux_bit layer24(layer2OUT[4], layer1OUT[4], layer1OUT[6], DATA2[1]);
    mux_bit layer25(layer2OUT[5], layer1OUT[5], layer1OUT[7], DATA2[1]);
    mux_bit layer26(layer2OUT[6], layer1OUT[6], layer1OUT[0], DATA2[1]);
    mux_bit layer27(layer2OUT[7], layer1OUT[7], layer1OUT[1], DATA2[1]);
  
    // MUX Layer 3
    mux_bit layer30(layer3OUT[0], layer2OUT[0], layer2OUT[4], DATA2[2]);    
    mux_bit layer31(layer3OUT[1], layer2OUT[1], layer2OUT[5], DATA2[2]);
    mux_bit layer32(layer3OUT[2], layer2OUT[2], layer2OUT[6], DATA2[2]);
    mux_bit layer33(layer3OUT[3], layer2OUT[3], layer2OUT[7], DATA2[2]);
    mux_bit layer34(layer3OUT[4], layer2OUT[4], layer2OUT[0], DATA2[2]);
    mux_bit layer35(layer3OUT[5], layer2OUT[5], layer2OUT[1], DATA2[2]);
    mux_bit layer36(layer3OUT[6], layer2OUT[6], layer2OUT[2], DATA2[2]);
    mux_bit layer37(layer3OUT[7], layer2OUT[7], layer2OUT[3], DATA2[2]);

    // Assigning final output after 2 time unit delay
    // If shift amount is 8, then output >>>> 8'd0
    assign #2 OUTPUT = (DATA2 == 8'd8) ? DATA1 : layer3OUT;  
endmodule