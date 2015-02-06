///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 3.15: ALU controlled by state machine to add 4 numbers together
//                  Using Mealy FSM -> lower latency, less regs than Moore
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
// ALU from Figure 3.22a
module ALU (
	input 			clk,
	input 			selA,
	input [31:0] 	inpA, inpB,
	input 			wrA, wrB,
	input [1:0]		ALUop,
	output [31:0] 	ALUout
);

logic [31:0] A, B;

always_ff @ (posedge clk) begin
	if (wrA)	A	<= selA ? inpA : ALUout;
	if (wrB)	B	<= inpB;
end

assign ALUout = (ALUop == 0)	?	0	:
				(ALUop == 1)	?	A	:
				(ALUop == 2)	?	B	:
									A+B;

endmodule

///////////////////////////////////////////////////////////////////////////////
// FSM for Excercise 3.15
module ex_3_15 (
	input clk,
	input reset,
	input [31:0] inpA, inpB,
	input dv,
	output [31:0] ALUout
);

// Number of inputs for each data valid
parameter NR_INPS = 4;

//=============================================================================
// ALU
logic 			selA, wrA, wrB;

enum logic [1:0] { zero = 0, A = 1, B = 2, add = 3} ALUop;

ALU ALU ( .* );

//=============================================================================
// Main state machine
enum {IDLE,	CLEAR, ENABLE} state;

logic [$clog2(NR_INPS)-1:0] counter;
logic count_en;
wire count_done;
assign count_done = counter == NR_INPS-1;

// FSM
always_ff @ (posedge clk) begin
	if (reset) begin
		state		<= IDLE;
		count_en	<= 0;
	end else begin
		case (state)
		//-------------------------------------------------
		IDLE:	begin
			if (dv) begin
				state		<= ENABLE;
				count_en	<= 1;
			end
		end	
		//-------------------------------------------------
		ENABLE:	begin
			if (count_done) 	state	<= IDLE;
		end
		//-------------------------------------------------
		default:				state	<= IDLE;
		//-------------------------------------------------
		endcase
	end
end

// FSM outputs
assign wrA		= dv || (state == ENABLE);
assign wrB  	= 1'b1;
assign selA 	= 1'b0;
assign ALUop	=  dv               ? zero :
				  (state == ENABLE)	? add  :
				                      A;

// Counter
always_ff @ (posedge clk) begin
	if (reset || !count_en) 	counter	<= 0;
	else						counter	<= counter + 1;
end

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_3_15_tb;

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
	
// Stimuli
bit [31:0] inpA = 0, inpB = 0;
bit dv = 0;

always @ (posedge clk) inpB <= inpB + 1;

// Responses
wire [31:0] ALUout;

// Module
ex_3_15 DUT ( .* );


// Main program
initial begin
	int first, sum;
	$display(" === FSM in HW, ex 3.15 === ");
	$display(" ===   using Mealy FSM  === ");
	
	assert_reset();

	@ (posedge clk);
	dv 			<= 1;
	#1 first	<= inpB;

	@ (posedge clk);
	dv 			<= 0;

	#(6*Tclk);
	sum = first + first+1 + first+2 + first+3;
	$display("Result should be: %d", sum);
	if (sum == ALUout)
		$display(" [ OK  ] FSM output: %d", ALUout);
	else
		$display(" [Error] FSM output: %d", ALUout);

	
	$stop();
end

endmodule
