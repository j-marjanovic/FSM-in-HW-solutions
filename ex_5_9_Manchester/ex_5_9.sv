///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.9: Manchester encoder
// 
//         /-----\         /-----\
//         |  A  |-------->|  B  |
//         | y=1 |<--------| y=0 |
//         \-----/   x=0   \-----/
//            A               |   
//            |               |  
//            | x=1           | x=1
//            |               |  
//            |               V   
//         /-----\         /-----\
//         |  D  |<--------|  C  |
//         | y=1 |-------->| y=0 |
//         \-----/   x=0   \-----/        
//         
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
module ex_5_9 (
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
			A:			state	<= B;
			//-----------------------------------
			B:	if (x)	state	<= C;
				else	state	<= A;
			//-----------------------------------
			C:			state	<= D;
			//-----------------------------------
			D:	if (x)	state	<= A;
				else	state	<= C;
			//-----------------------------------
			default:	state	<= A;
			endcase
		end
	end
end

// FSM outputs
assign y = (state == A) || (state == D);

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_9_tb;

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

ex_5_9 DUT ( .* );


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
