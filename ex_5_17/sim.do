###############################################################################
#
#  Solved exercises from:
#    Finite State Machines in Hardware by Volnei A. Pedroni
#
#  This file was written by Jan Marjanovic, 2015
#
#  Excersise 5.17: FLag Monitor
###############################################################################

# Script for ModelSim 

if { [file exists work] } { vdel -lib work -all }

vlib work

vlog -sv ex_5_17.sv

vsim work.ex_5_17_tb

add wave -divider "Clk and reset"
add wave -position insertpoint sim:/ex_5_17_tb/clk sim:/ex_5_17_tb/reset

add wave -divider "Inputs and output"
add wave -position insertpoint \
	sim:/ex_5_17_tb/window	\
	sim:/ex_5_17_tb/flag_in	\
	sim:/ex_5_17_tb/flag_out

add wave -divider "Internal"
add wave -position insertpoint \
	sim:/ex_5_17_tb/DUT/state

run -All
