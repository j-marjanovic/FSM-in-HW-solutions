///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.14: Keypad Encoder
//     State machine scans columns continously until a pressed button is 
//     detected. In that case it stays in that column until button is 
//     released.
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
module keypad (
	output reg	[3:0]	r,
	input		[2:0]	c
);

logic [3:0] r_internal [3] = { 4'b1111, 4'b1111, 4'b1111};

always_comb begin
	case (c)
	3'b110: r = r_internal[0];
	3'b101: r = r_internal[1];
	3'b011: r = r_internal[2];
	default: r = 4'b1111;	
	// here should be checked if no more than 1 column is addressed
	endcase
end

task press_key (input byte key);
	case (key)
	"1": r_internal[2] = 4'b0111;
	"4": r_internal[2] = 4'b1011;
	"7": r_internal[2] = 4'b1101;
	"*": r_internal[2] = 4'b1110;
	"2": r_internal[1] = 4'b0111;
	"5": r_internal[1] = 4'b1011;
	"8": r_internal[1] = 4'b1101;
	"0": r_internal[1] = 4'b1110;
	"3": r_internal[0] = 4'b0111;
	"6": r_internal[0] = 4'b1011;
	"9": r_internal[0] = 4'b1101;
	"#": r_internal[0] = 4'b1110;
	endcase
endtask

task release_key ();
	r_internal = { 4'b1111, 4'b1111, 4'b1111};
endtask

endmodule


///////////////////////////////////////////////////////////////////////////////
module ex_5_14 (
	input 				clk,
	input 				reset,
	input 		[3:0]	r,
	output reg	[2:0]	c,
	output reg	[3:0]	key
);

//=============================================================================
// Main state machine
enum { A, B, C } state;


// FSM
always_ff @ (posedge clk) begin
	if (reset) begin
		state <= A;
	end else begin
		case (state)
		//-----------------------------------
		A:	if (r == 4'b1111)	state	<= B;
		//-----------------------------------
		B:	if (r == 4'b1111)	state	<= C;
		//-----------------------------------
		C:	if (r == 4'b1111)	state	<= A;
		//-----------------------------------
		default:				state	<= A;
		//-----------------------------------
		endcase
	end
end

always_comb begin
	case (state)
	//-----------------------------------
	A:	begin
		c 	= 3'b110;
		case (r)
		4'b1111: key = 4'b1111;
		4'b1110: key = 4'b1011;
		4'b1101: key = 4'b1001;
		4'b1011: key = 4'b0110;
		4'b0111: key = 4'b0011;
		endcase
	end
	//-----------------------------------
	B: begin
		c = 3'b101;
		case (r)
		4'b1111: key = 4'b1111;
		4'b1110: key = 4'b0000;
		4'b1101: key = 4'b1000;
		4'b1011: key = 4'b0101;
		4'b0111: key = 4'b0010;
		endcase
	end
	//-----------------------------------
	C: begin
		c = 3'b011;
		case (r)
		4'b1111: key = 4'b1111;
		4'b1110: key = 4'b1010;
		4'b1101: key = 4'b0111;
		4'b1011: key = 4'b0100;
		4'b0111: key = 4'b0001;
		endcase
	end
	//-----------------------------------
	default: begin
		c = 3'b111;
	end
	//-----------------------------------
	endcase
end

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_14_tb;

localparam time Tclk = 10;

// Clock generator
bit clk = 0;
always #(Tclk/2) clk = !clk;


// Reset generator
bit reset = 0;
task assert_reset();
	#(Tclk);
	reset	= 1;
	#(Tclk);
	reset	= 0;
	#(Tclk);
endtask
	
// Modules
wire [3:0] r;
wire [2:0] c;
wire [3:0] key;

keypad keypad ( .* );

ex_5_14 DUT ( .* );


// Main program
initial begin
	$display(" ===  FSM in HW, ex 5.14 === ");
	$display(" ===    Keypad Encoder   === ");
	
	assert_reset();
	
	keypad.press_key("1");	#(4*Tclk);	assert (key == 1);
	keypad.release_key();

	keypad.press_key("6");	#(4*Tclk);	assert (key == 6);
	keypad.release_key();

	keypad.press_key("#");	#(4*Tclk);	assert (key == 11);
	keypad.release_key();

	keypad.press_key("0");	#(4*Tclk);	assert (key == 0);
	keypad.release_key();

	#(5*Tclk);

	$stop();
end

endmodule
