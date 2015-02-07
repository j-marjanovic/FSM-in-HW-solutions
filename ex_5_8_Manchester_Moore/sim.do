###############################################################################
#
#  Solved exercises from:
#    Finite State Machines in Hardware by Volnei A. Pedroni
#
#  This file was written by Jan Marjanovic, 2015
#
#  Excersise 5.8:  Manchester encoder
###############################################################################

# Script for ModelSim 

if { [file exists work] } { vdel -lib work -all }

vlib work

vlog -sv ex_5_8.sv

vsim work.ex_5_8_tb

add wave -divider "Clk and reset"
add wave -position insertpoint sim:/ex_5_8_tb/clk sim:/ex_5_8_tb/reset

add wave -divider "Input"
add wave -position insertpoint -radix binary \
	sim:/ex_5_8_tb/dv	\
	sim:/ex_5_8_tb/x	\

add wave -divider "Output"
add wave -position insertpoint -radix binary \
	sim:/ex_5_8_tb/y


add wave -divider "Internal"
add wave -position insertpoint	\
	sim:/ex_5_8_tb/DUT/state	


run -All

