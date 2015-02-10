///////////////////////////////////////////////////////////////////////////////
//
//  Solved exercises from:
//    Finite State Machines in Hardware by Volnei A. Pedroni
//
//  This file was written by Jan Marjanovic, 2015
//
//  Excersise 5.15: Square Root Calculator
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

///////////////////////////////////////////////////////////////////////////////
module ex_5_16 (
	input 				clk,
	input 				reset,
	input 				dv,
	input unsigned	[31:0]	inpA, inpB,
	output reg	[31:0]	y,
	output reg			y_valid
);

//===============================================
reg [31:0] a, b;
reg ab_valid;
always @ (posedge clk) begin
	if (reset) begin
		ab_valid	<= 1'b0;
	end else begin
		ab_valid	<= dv;
		if (dv) begin
			if (inpA > inpB) begin
				a	<= inpA;
				b	<= inpB;
			end else begin
				a	<= inpB;
				b	<= inpA;
			end
		end
	end
end

//===============================================
// aditional pipeline stage can be added here if needed
wire [31:0] a_div_8, b_div_2, a1;
wire div_valid;

assign a_div_8 = {3'd0, a[31:3]};
assign b_div_2 = {1'b0, b[31:1]};
assign div_valid = ab_valid;
assign a1 = a;

//===============================================
reg [31:0] sum, a2;
reg sum_valid;

always @ (posedge clk) begin
	if (reset) begin
		sum_valid	<= 1'b0;
	end else begin
		sum_valid	<= div_valid;
		a2			<= a1;
		sum			<= a - a_div_8 + b_div_2; 
	end
end

//===============================================
always @ (posedge clk) begin
	if (reset) begin
		y_valid		<= 1'b0;
	end else begin
		y_valid		<= sum_valid;
		y			<= ( sum > a2 ) ? sum : a2;
	end
end

endmodule

///////////////////////////////////////////////////////////////////////////////
// Testbench
module ex_5_16_tb;

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
wire 		y_valid;

// Module
ex_5_16 DUT ( .* );

int stim[$], resp[$];

// Checker
always @ (posedge clk) begin
	if (y_valid) resp.push_front(y);
end

task check();
	automatic int nr = 0;
	automatic real sum = 0;
	real error;
	
	$display("\tTrue\t Aprox\t  [Error %%]");
	$display("--------------------------------------");
	while(stim.size() != 0) begin
		int s, r;
		s = stim.pop_back();
		r = resp.pop_back();
		nr++;
		error = (s-r)*100.0/s;
		sum = sum + error*error;
		$display("%d %d  [%.2f %%]", s, r, error);
	end

	$display("--------------------------------------");
	$display("error mean: %f %%\n", $sqrt(sum) / nr );
endtask

// Main program
initial begin
	$display(" ===     FSM in HW, ex 5.16     === ");
	$display(" ===   Root Square Calculator   === ");
	
	assert_reset();

	repeat(100) begin
		@(posedge clk);	
		dv		= $random() % 2;
		inpA	= {$random} % 1000;
		inpB	= {$random} % 1000;
		if (dv)	stim.push_front($sqrt(inpA*inpA + inpB*inpB));
	end


	#(5*Tclk);

	check();

	$stop();
end

endmodule
