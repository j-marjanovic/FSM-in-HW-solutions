###############################################################################
#
#  Solved exercises from:
#    Finite State Machines in Hardware by Volnei A. Pedroni
#
#  This file was written by Jan Marjanovic, 2015
#
#  Excersise 5.14: Keyboard Encoder
###############################################################################

# Script for ModelSim 

if { [file exists work] } { vdel -lib work -all }

vlib work

vlog -sv ex_5_14.sv

vsim work.ex_5_14_tb

add wave -divider "Clk and reset"
add wave -position insertpoint sim:/ex_5_14_tb/clk sim:/ex_5_14_tb/reset

add wave -divider "Keyboard"
add wave -position insertpoint -radix binary \
	sim:/ex_5_14_tb/r	\
	sim:/ex_5_14_tb/c	\
	

add wave -divider "Output"
add wave -position insertpoint -radix binary \
	sim:/ex_5_14_tb/key


add wave -divider "Internal"
add wave -position insertpoint	\
	sim:/ex_5_14_tb/DUT/state	


run -All

