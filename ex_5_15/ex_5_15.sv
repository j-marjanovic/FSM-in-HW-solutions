///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.15: Largest-value Detector
//    Largest value is stored in register A and is put on the output when
//    data valid goes low.
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

logic [31:0] A = 0, B = 0;

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
module ex_5_15 (
	input 				clk,
	input 				reset,
	input 				dv,
	input		[31:0]	inpB,
	output 		[31:0]	y
);

//=============================================================================
// ALU
logic	selA, selB, wrA, wrB;
enum logic [1:0] { A = 0, B = 1, A_m_B = 2, B_m_A = 3 } ALUop;
wire [1:0] sign;	

ALU ALU ( .ALUout(y), .inpA(), .* );


//=============================================================================
// Main state machine
enum { IDLE, LOAD, WAIT, STORE_A, STORE_B } state;


// FSM
always_ff @ (posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end else begin
		case (state)
		//-------------------------------------------------
		IDLE:	if (dv)				state	<= LOAD;
		//-------------------------------------------------
		LOAD:	if (!dv)			state	<= IDLE;
				else				state	<= WAIT;
		//-------------------------------------------------
		WAIT:	if (!dv)			state	<= IDLE;
				else if (sign==2'b01)	state	<= STORE_A;
				else				state	<= STORE_B;
		//-------------------------------------------------
		STORE_A, 
		STORE_B:	if (!dv)		state	<= IDLE;
					else			state	<= LOAD;
		//-------------------------------------------------
		default:					state	<= IDLE;
		//-------------------------------------------------
		endcase
	end
end


// FSM outputs
assign selA = 1'b0; // feedback from ALU
assign selB = 1'b1; // external stream of data

always_comb begin
	case (state)
	//-----------------------------------
	IDLE: begin
		wrA	= 1'b0;
		wrB = 1'b0;
		ALUop = A;
	end
	//-----------------------------------
	LOAD: begin
		wrA	= 1'b0;
		wrB = 1'b1;
		ALUop = A_m_B;
	end
	//-----------------------------------
	WAIT: begin
		wrA	= 1'b0;
		wrB = 1'b0;
		ALUop = A_m_B;
	end
	//-----------------------------------
	STORE_A: begin
		wrA	= 1'b1;
		wrB = 1'b0;
		ALUop = A;
	end
	//-----------------------------------
	STORE_B: begin
		wrA	= 1'b1;
		wrB = 1'b0;
		ALUop = B;
	end
	//-----------------------------------
	default: begin
		wrA	= 1'b0;
		wrB = 1'b0;
		ALUop = A;
	end
	//-----------------------------------
	endcase
end

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_15_tb;

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
wire [31:0] y;

// Module
ex_5_15 DUT ( .* );


// Main program
initial begin
	$display(" ===      FSM in HW, ex 5.15     === ");
	$display(" ===    Largest-value Detector   === ");
	
	assert_reset();
	
	@(posedge clk);
	dv		<= 1;
	inpB	<= 3;

	repeat (4) @(posedge clk);
	inpB	<= 5;

	repeat (3) @(posedge clk);
	inpB	<= 2;

	repeat (3) @(posedge clk);
	inpB	<= 7;

	repeat (3) @(posedge clk);
	inpB	<= 11;

	repeat (3) @(posedge clk);
	inpB	<= 0;

	repeat (3) @(posedge clk);
	dv		<= 0;

	#(5*Tclk);

	$stop();
end

endmodule
