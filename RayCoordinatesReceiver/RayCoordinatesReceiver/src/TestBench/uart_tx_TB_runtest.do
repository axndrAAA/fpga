SetActiveLib -work
comp -include "$dsn\src\uart_TX.vhd" 
comp -include "$dsn\src\TestBench\uart_tx_TB.vhd" 
asim +access +r TESTBENCH_FOR_uart_tx 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg data_in
wave -noreg data_in_rdy
wave -noreg uart_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\uart_tx_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_uart_tx 
