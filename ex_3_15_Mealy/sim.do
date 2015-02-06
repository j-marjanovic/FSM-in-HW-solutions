###############################################################################
#
#  Solved exercises from:
#    Finite State Machines in Hardware by Volnei A. Pedroni
#
#  This file was written by Jan Marjanovic, 2015
#
#  Excersise 3.15: ALU controlled by state machine to add 4 numbers together
#                  Using Mealy FSM -> lower latency, less regs than Moore
###############################################################################

# Script for ModelSim 

if { [file exists work] } { vdel -lib work -all }

vlib work

vlog -sv ex_3_15_Mealy.sv

vsim work.ex_3_15_tb


add wave -divider "Clk and reset"
add wave -position insertpoint sim:/ex_3_15_tb/clk sim:/ex_3_15_tb/reset

add wave -divider "Inputs and output"
add wave -position insertpoint -radix unsigned \
	sim:/ex_3_15_tb/inpA 		\
	sim:/ex_3_15_tb/inpB 		\
	sim:/ex_3_15_tb/ALUout

add wave -divider "Internal"
add wave -position insertpoint	\
	sim:/ex_3_15_tb/DUT/dv 		\
	sim:/ex_3_15_tb/DUT/selA 	\
	sim:/ex_3_15_tb/DUT/wrA		\
	sim:/ex_3_15_tb/DUT/wrB		\
	sim:/ex_3_15_tb/DUT/ALUop	\
	sim:/ex_3_15_tb/DUT/state	

add wave -position insertpoint -radix unsigned sim:/ex_3_15_tb/DUT/counter


run -All
