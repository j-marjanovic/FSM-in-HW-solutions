///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.7: Manchester encoder
//         
//         /-----\   x     /-----\
//         |  A  |-------> |  B  |
//         | y=0 |         | y=0 |
//         \-----/         \-----/
//          A  |            A   | 
//          |  |            |   |
//          |  | !x       x |   | 
//          |  |            |   |
//          |  V            |   V 
//         /-----\    !x   /-----\
//         |  D  | <-------|  C  |
//         | y=1 |         | y=1 |
//         \-----/         \-----/
//         
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
module ex_5_8 (
	input 			clk,
	input 			reset,
	input 			dv, x,
	output			y
);

//=============================================================================
// Main state machine
enum { A, B, C, D } state;


// FSM
always_ff @ (posedge clk) begin
	if (reset) begin
		state <= A;
	end else begin
		if (dv) begin
			case (state)
			//-----------------------------------
			A:	if (x)	state	<= B;
				else	state	<= D;
			//-----------------------------------
			B:			state	<= C;
			//-----------------------------------
			C:	if (x)	state	<= B;
				else	state	<= D;
			//-----------------------------------
			D:			state	<= A;
			//-----------------------------------
			default:	state	<= A;
			endcase
		end
	end
end

// FSM outputs
assign y = (state == C) || (state == D);

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_8_tb;

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
bit dv = 0, x = 0;
wire y;

ex_5_8 DUT ( .* );


// Main program
initial begin
	$display(" ===    FSM in HW, ex 5.8   === ");
	$display(" ===   Manchester  encoder  === ");
	
	assert_reset();
	
	@(posedge clk);
	dv	<= 1;
	x	<= 0;

	@(posedge clk);
	@(posedge clk);
	x	<= 1;

	@(posedge clk);
	@(posedge clk);
	x	<= 0;

	@(posedge clk);
	@(posedge clk);
	x	<= 0;

	@(posedge clk);
	@(posedge clk);
	x	<= 1;

	@(posedge clk);
	@(posedge clk);
	x	<= 0;

	#(2*Tclk);

	$stop();
end

endmodule
