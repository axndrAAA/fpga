library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity rs_in_tb is
end rs_in_tb;

architecture TB_ARCHITECTURE of rs_in_tb is
	-- Component declaration of the tested unit
	component rs_in
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		uart_in : in STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR(7 downto 0);
		data_rdy : out STD_LOGIC;
		test_out1	: out std_logic_vector(1 downto 0));
	end component;
	
	--Stimulus constants
	constant c_BIT_PERIOD : time := 8680 ns;
	
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC:='0';
	signal reset : STD_LOGIC;
	signal uart_in : STD_LOGIC:='1';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal data_out : STD_LOGIC_VECTOR(7 downto 0);
	signal data_rdy : STD_LOGIC;
	signal test_out1	:  std_logic_vector(1 downto 0);

	--процедура передачи сообщения на uart_in
	procedure UART_WRITE_BYTE (
    	i_data_in       : in  std_logic_vector(7 downto 0);
    	signal o_serial : out std_logic) is
 	begin
 
    	-- Send Start Bit
    	o_serial <= '0';
    	wait for c_BIT_PERIOD;
 
    	-- Send Data Byte
    	for ii in 0 to 7 loop
      		o_serial <= i_data_in(ii);
      	wait for c_BIT_PERIOD;
    	end loop;  -- ii
 
    	-- Send Stop Bit
    	o_serial <= '1';
    	wait for c_BIT_PERIOD;
  	end UART_WRITE_BYTE;
	

begin

	-- Unit Under Test port map
	UUT : rs_in
		port map (
			clk => clk,
			reset => reset,
			uart_in => uart_in,
			data_out => data_out,
			data_rdy => data_rdy,	
			test_out1 =>test_out1
		);

	-- Add your stimulus here ...
	
	clk	<= not clk after 5 ns; 		   
	
process is
begin		   
	wait for 2000 ns;
	UART_WRITE_BYTE(B"11111111", uart_in);	 
	wait for 20 ms;
end process;


end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_rs_in of rs_in_tb is
	for TB_ARCHITECTURE
		for UUT : rs_in
			use entity work.rs_in(rs_in);
		end for;
	end for;
end TESTBENCH_FOR_rs_in;

