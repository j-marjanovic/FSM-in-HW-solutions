///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.4.8
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
// ALU from Figure 5.13a
module ALU (
	input 			clk,
	input 			selA, selB,
	input 	[31:0] 	inpA, inpB,
	input 			wrA, wrB,
	input 	[ 1:0]	ALUop,
	output signed	[31:0] 	ALUout,
	output	[ 1:0]	sign
);

logic [31:0] A, B;

always_ff @ (posedge clk) begin
	if (wrA)	A	<= selA ? inpA : ALUout;
	if (wrB)	B	<= selB ? inpB : ALUout;
end

assign ALUout = (ALUop == 0)	?	A	:
				(ALUop == 1)	?	B	:
				(ALUop == 2)	?	A-B	:
									B-A ;

assign sign = 	(ALUout == 0)	?	2'b00	:
				(ALUout >  0)	?	2'b01	:
				/* ALUout < 00 */	2'b10	; 

endmodule

///////////////////////////////////////////////////////////////////////////////
module ex_5_4_8 (
	input 			clk,
	input 			reset,
	input 	[31:0] 	inpA, inpB,
	input 			dv,
	output 	[31:0] 	ALUout
);

//=============================================================================
// ALU
logic	selA, selB, wrA, wrB;
enum logic [1:0] { A = 0, B = 1, A_m_B = 2, B_m_A = 3 } ALUop;
wire [1:0] sign;	

ALU ALU ( .* );

//=============================================================================
// Main state machine
enum {S_IDLE, S_LOAD, S_WAIT, S_WRITE_A, S_WRITE_B} state;


// FSM
always_ff @ (posedge clk) begin
	if (reset) begin
		state		<= S_IDLE;
	end else begin
		case (state)
		//-------------------------------------------------
		S_IDLE:	if (dv)			state	<= S_LOAD;
		//-------------------------------------------------
		S_LOAD:					state	<= S_WAIT;
		//-------------------------------------------------
		S_WAIT:	priority case (sign)
				2'b00:			state	<= S_IDLE;
				2'b01:			state	<= S_WRITE_A;
				2'b10:			state	<= S_WRITE_B;
				endcase					
		//-------------------------------------------------
		S_WRITE_A:				state	<= S_WAIT;
		//-------------------------------------------------
		S_WRITE_B:				state	<= S_WAIT;
		//-------------------------------------------------
		default:				state	<= S_IDLE;
		//-------------------------------------------------
		endcase
	end
end

// FSM outputs
always_comb begin
	case (state)
	//-------------------------------------------------
	S_IDLE:	begin
		selA	= 1'b0;
		selB	= 1'b0;
		wrA		= 1'b0;
		wrB		= 1'b0;
		ALUop	= A;
	end
	//-------------------------------------------------
	S_LOAD: begin
		selA	= 1'b1;
		selB	= 1'b1;
		wrA		= 1'b1;
		wrB		= 1'b1;
		ALUop	= A;
	end
	//-------------------------------------------------
	S_WAIT: begin
		selA	= 1'b0;
		selB	= 1'b0;
		wrA		= 1'b0;
		wrB		= 1'b0;
		ALUop	= A_m_B;
	end				
	//-------------------------------------------------
	S_WRITE_A: begin
		selA	= 1'b0;
		selB	= 1'b0;
		wrA		= 1'b1;
		wrB		= 1'b0;
		ALUop	= A_m_B;
	end
	//-------------------------------------------------
	S_WRITE_B: begin
		selA	= 1'b0;
		selB	= 1'b0;
		wrA		= 1'b0;
		wrB		= 1'b1;
		ALUop	= B_m_A;
	end
	//-------------------------------------------------
	default: begin
		selA	= 1'b0;
		selB	= 1'b0;
		wrA		= 1'b0;
		wrB		= 1'b0;
		ALUop	= A;
	end
	//-------------------------------------------------
	endcase
end

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_4_8_tb;

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


// Responses
wire [31:0] ALUout;

// Module
ex_5_4_8	 DUT ( .* );


// Tasks
task load_numbers(input int a, input int b);
	@ (posedge clk);
	dv 			<= 1;
	inpA		<= a;
	inpB		<= b;

	@ (posedge clk);
	dv 			<= 0;


	#1	wait(DUT.state == DUT.S_IDLE);
	#1	$display("GCD of %d and %d = %d", a, b, ALUout);

endtask


// Main program
initial begin
	$display(" ===    FSM in HW, ex 5.4.8   === ");
	$display(" ===  Greatest common divisor === ");
	
	assert_reset();

	load_numbers(9, 15);
	#(Tclk);	

	load_numbers(9*16, 15*8);
	#(Tclk);

	$stop();
end

endmodule
