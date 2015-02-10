###############################################################################
#
#  Solved exercises from:
#    Finite State Machines in Hardware by Volnei A. Pedroni
#
#  This file was written by Jan Marjanovic, 2015
#
#  Excersise 5.16: Square Root Calculator
###############################################################################

# Script for ModelSim 

if { [file exists work] } { vdel -lib work -all }

vlib work

vlog -sv ex_5_16_datapath.sv

vsim work.ex_5_16_tb

add wave -divider "Clk and reset"
add wave -position insertpoint sim:/ex_5_16_tb/clk sim:/ex_5_16_tb/reset

add wave -divider "Inputs and output"
add wave -position insertpoint -radix unsigned \
	sim:/ex_5_16_tb/dv		\
	sim:/ex_5_16_tb/inpA 		\
	sim:/ex_5_16_tb/inpB 		\
	sim:/ex_5_16_tb/y		\
	sim:/ex_5_16_tb/y_valid




run -All

