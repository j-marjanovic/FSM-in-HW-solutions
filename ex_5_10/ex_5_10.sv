///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.10: Time-Ordered "111" Detector
//         
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
module ex_5_10 (
	input 			clk,
	input 			reset,
	input 			a, b, c,
	output			x
);

//=============================================================================
// Main state machine
enum { IDLE, A, B, C } state;


// FSM
always_ff @ (posedge clk) begin
	if (reset) begin
		state <= A;
	end else begin
		case (state)
		IDLE: if(a)			state	<= A;
		//-----------------------------------
		A:	if (!a)			state	<= A;
			else if (b)		state	<= B;
		//-----------------------------------
		B:	if (!a || !b)	state	<= A;
			else if (c)		state	<= C;
		//-----------------------------------
		C:					state	<= A;
		//-----------------------------------
		default:	state	<= A;
		endcase
	end
end

// FSM outputs
assign x = (state == C);

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_10_tb;

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
	
// Module
bit a = 0, b = 0, c = 0;
wire x;

ex_5_10 DUT ( .* );


// Main program
initial begin
	$display(" ===        FSM in HW, ex 5.10      === ");
	$display(" ===   Time-Ordered '111' detector  === ");
	
	assert_reset();
	
	@(posedge clk);
	a	<= 0;
	b	<= 0;
	c	<= 1;

	@(posedge clk);
	a	<= 1;
	b	<= 1;
	c	<= 1;

	@(posedge clk);
	a	<= 0;
	b	<= 0;
	c	<= 0;

	@(posedge clk);
	a	<= 1;
	b	<= 1;
	c	<= 0;

	@(posedge clk);
	a	<= 1;
	b	<= 1;
	c	<= 1;

	@(posedge clk);
	a	<= 1;
	b	<= 1;
	c	<= 0;

	@(posedge clk);
	a	<= 1;
	b	<= 1;
	c	<= 1;

	@(posedge clk);
	a	<= 0;
	b	<= 1;
	c	<= 0;

	@(posedge clk);
	a	<= 0;
	b	<= 0;
	c	<= 0;

	#(2*Tclk);

	$stop();
end

endmodule
