///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.7: Arbiter
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
module ex_5_7 (
	input 			clk,
	input 			reset,
	input 	[2:0] 	req,
	output	[2:0]	grant

);

//=============================================================================
// Main state machine
enum { IDLE, GRANT0, GRANT1, GRANT2 } state;


// FSM
always_ff @ (posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end else begin
		case (state)
		//-----------------------------------------------------------
		IDLE:	if 		( req[0] )				state	<= GRANT0;
				else if ( req[1] )				state	<= GRANT1;
				else if ( req[2] )				state	<= GRANT2;
		//-----------------------------------------------------------
		GRANT0:	if 		( !req[0] && req[1] )	state	<= GRANT1;
				else if ( !req[0] && req[2] )	state	<= GRANT2;
				else if ( !req[0] )				state	<= IDLE;
		//-----------------------------------------------------------
		GRANT1:	if 		( !req[1] && req[0] )	state	<= GRANT0;
				else if ( !req[1] && req[2] )	state	<= GRANT2;
				else if ( !req[1] )				state	<= IDLE;
		//-----------------------------------------------------------
		GRANT2:	if 		( !req[2] && req[0] )	state	<= GRANT0;
				else if ( !req[2] && req[1] )	state	<= GRANT1;
				else if ( !req[2] )				state	<= IDLE;
		//-----------------------------------------------------------
		default:								state	<= IDLE;
		//-----------------------------------------------------------
		endcase
	end
end

// FSM outputs
assign grant = 	(state == GRANT0)	?	3'b001	:
				(state == GRANT1)	?	3'b010	:
				(state == GRANT2)	?	3'b100	:
										3'b000	;

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_7_tb;

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
bit [2:0] req;
wire [2:0] grant;

ex_5_7 DUT ( .* );


// Main program
initial begin
	$display(" ===    FSM in HW, ex 5.7   === ");
	$display(" ===         Arbiter        === ");
	
	assert_reset();
	#1;

	// Check highest priority grant
	req	= 3'b001;
	@ (posedge clk); #1; 	assert ( grant == 3'b001 );

	// Check if additional request disturbs FSM
	req	= 3'b011;
	@ (posedge clk); #1; 	assert ( grant == 3'b001 ); 

	// Check if grants next request when one finishes
	req	= 3'b010;
	@ (posedge clk); #1; 	assert ( grant == 3'b010 ); 

	// Check if FSM releases grants
	req	= 3'b000;
	@ (posedge clk); #1; 	assert ( grant == 3'b000 ); 

	// Check if FSM grants lower request
	req	= 3'b100;
	@ (posedge clk); #1; 	assert ( grant == 3'b100 ); 

	// Check if additional request with higher priority disturbs FSM
	req	= 3'b101;
	@ (posedge clk); #1; 	assert ( grant == 3'b100 ); 

	// Check if FSM releases grants
	req	= 3'b000;
	@ (posedge clk); #1; 	assert ( grant == 3'b000 ); 

	// Check priority
	req	= 3'b111;
	@ (posedge clk); #1; 	assert ( grant == 3'b001 ); 

	// Check if FSM releases grants
	req	= 3'b000;
	@ (posedge clk); #1; 	assert ( grant == 3'b000 ); 

	#(2*Tclk);

	$stop();
end

endmodule
