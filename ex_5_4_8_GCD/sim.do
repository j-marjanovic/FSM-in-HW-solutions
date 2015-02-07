###############################################################################
#
#  Solved exercises from:
#    Finite State Machines in Hardware by Volnei A. Pedroni
#
#  This file was written by Jan Marjanovic, 2015
#
#  Excersise 5.4.8: Greatest common divisor
###############################################################################

# Script for ModelSim 

if { [file exists work] } { vdel -lib work -all }

vlib work

vlog -sv ex_5_4_8_GCD.sv

vsim work.ex_5_4_8_tb


add wave -divider "Clk and reset"
add wave -position insertpoint sim:/ex_5_4_8_tb/clk sim:/ex_5_4_8_tb/reset

add wave -divider "Inputs and output"
add wave -position insertpoint -radix unsigned \
	sim:/ex_5_4_8_tb/inpA 		\
	sim:/ex_5_4_8_tb/inpB 		\
	sim:/ex_5_4_8_tb/dv

add wave -divider "ALU"
add wave -position insertpoint -radix decimal \
	sim:/ex_5_4_8_tb/DUT/ALU/A 		\
	sim:/ex_5_4_8_tb/DUT/ALU/B		\
	sim:/ex_5_4_8_tb/DUT/ALU/ALUout	
add wave -position insertpoint -radix binary \
	sim:/ex_5_4_8_tb/DUT/ALU/sign	


add wave -divider "Internal"
add wave -position insertpoint	\
	sim:/ex_5_4_8_tb/DUT/selA 	\
	sim:/ex_5_4_8_tb/DUT/selB 	\
	sim:/ex_5_4_8_tb/DUT/wrA	\
	sim:/ex_5_4_8_tb/DUT/wrB	\
	sim:/ex_5_4_8_tb/DUT/ALUop	\
	sim:/ex_5_4_8_tb/DUT/state	


run -All
