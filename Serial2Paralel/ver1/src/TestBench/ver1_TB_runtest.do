SetActiveLib -work
comp -include "$dsn\src\ver1.vhd" 
comp -include "$dsn\src\TestBench\ver1_TB.vhd" 
asim +access +r TESTBENCH_FOR_ver1 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg uart_in
wave -noreg data_out
wave -noreg data_rdy
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\ver1_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_ver1 
