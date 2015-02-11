///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.17: Flag Monitor
//
//
//
//             +--------+                             
//             | STORE1 |                             
//             |  y=1   |\                            
//             +--------+ \                           
//                         \                          
//                          \                         
//                           \                        
//                            \+-----+                
//                             | AT1 |                
//                             | y=y |                
//                             +-----+\               
//                                     \              
//                                      \             
//                                       \            
//          +-------+                     \+---------+
//          | IDLE  |                      | INVALID |
//          |  y=0  |                      |   y=y   |
//          +-------+                     /+---------+
//                                       /            
//                                      /             
//                                     /              
//                             +-----+/               
//                             | AT0 |                
//                            /| y=y |                
//                           / +-----+                
//                          /                         
//                         /                          
//             +--------+ /                           
//             | STORE0 |/                            
//             |   y=0  |                             
//             +--------+                             
//          
//
//
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps


///////////////////////////////////////////////////////////////////////////////
module ex_5_17 (
	input 			clk,
	input 			reset,
	input 			window,
	input			flag_in,
	output 	reg 	flag_out
);

//=============================================================================
// Main state machine
enum { IDLE, AT1, AT0, INVALID, STORE1, STORE0 } state;

// transitions
always_ff @ (posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end else begin
		case (state)
		//-------------------------------------------------
		IDLE:	if (window && flag_in)			state <= AT1;
				else if (window && !flag_in)	state <= AT0;
 		//-------------------------------------------------
 		AT1:	if (!window)					state <= STORE1;
 				else if (window && !flag_in)	state <= INVALID;
 		//-------------------------------------------------
 		AT0:	if (!window)					state <= STORE0;
 				else if (window && flag_in)		state <= INVALID;
 		//-------------------------------------------------
 		STORE1:							state <= IDLE;
 		//-------------------------------------------------
 		STORE0:							state <= IDLE;
 		//-------------------------------------------------
 		INVALID: if (!window)			state <= IDLE;
		//-------------------------------------------------
		default:						state <= IDLE;
		//-------------------------------------------------
		endcase
	end
end


always_comb begin
	if (reset)
		flag_out = 1'b0;
	else
		case (state)
		STORE0:  flag_out = 1'b0;
		STORE1:  flag_out = 1'b1;
		default: flag_out = flag_out;
		endcase
end

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_17_tb;

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
endtask
	
// Stimuli
bit window = 0, flag_in = 0;

// Responses
wire flag_out;

// Module
ex_5_17 DUT ( .* );


// Main program
initial begin
	$display(" ===      FSM in HW, ex 5.15     === ");
	$display(" ===    Largest-value Detector   === ");
	
	assert_reset();
	
	@(posedge clk);
	window	<= 1;

	@(posedge clk);
	flag_in	<= 1;

	repeat (3) @(posedge clk);
	window 	<= 0;

	@(posedge clk);
	flag_in	<= 0;

	@(posedge clk);
	window	<= 1;
	flag_in	<= 1;

	repeat (3) @(posedge clk);
	window	<= 0;

	@(posedge clk);
	flag_in	<= 0;

	@(posedge clk);
	window	<= 1;

	repeat (1) @(posedge clk);
	flag_in	<= 1;

	repeat (2) @(posedge clk);
	flag_in	<= 0;

	@(posedge clk);
	window	<= 0;

	@(posedge clk);

	@(posedge clk);
	window	<= 1;

	repeat (3) @(posedge clk);
	window	<= 0;

	@(posedge clk);

	@(posedge clk);
	window	<= 1;

	@(posedge clk);
	flag_in	<= 1;

	repeat (3) @(posedge clk);
	window 	<= 0;

	@(posedge clk);
	flag_in	<= 0;

	@(posedge clk);
	$stop();
end

endmodule
