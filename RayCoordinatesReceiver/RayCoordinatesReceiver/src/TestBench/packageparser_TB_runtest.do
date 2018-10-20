SetActiveLib -work
comp -include "$dsn\src\PackageParser.vhd" 
comp -include "$dsn\src\TestBench\packageparser_TB.vhd" 
asim +access +r TESTBENCH_FOR_packageparser 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg module_adress
wave -noreg data_input
wave -noreg data_input_rdy
wave -noreg coord_data_rdy
wave -noreg command_rdy
wave -noreg LsinA
wave -noreg LsinB
wave -noreg command_output
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\packageparser_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_packageparser 
