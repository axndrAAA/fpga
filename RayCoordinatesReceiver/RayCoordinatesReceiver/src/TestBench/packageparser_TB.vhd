library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
	-- Add your library and packages declaration here ...

entity packageparser_tb is
end packageparser_tb;

architecture TB_ARCHITECTURE of packageparser_tb is
-- Component declaration of the tested unit
		component rs_in
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		uart_in : in STD_LOGIC;	
		
		data_out : out STD_LOGIC_VECTOR(7 downto 0);
		data_rdy : out STD_LOGIC
		);
	end component;
	
	component packageparser
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		module_adress : in STD_LOGIC_VECTOR(7 downto 0);
		data_input : in STD_LOGIC_VECTOR(7 downto 0);
		data_input_rdy : in STD_LOGIC;
		
		coord_data_rdy : out STD_LOGIC;
		command_rdy : out STD_LOGIC;
		LsinA : out STD_LOGIC_VECTOR(31 downto 0);
		LsinB : out STD_LOGIC_VECTOR(31 downto 0);
		command_output : out STD_LOGIC_VECTOR(7 downto 0) );
	end component;

	constant c_BIT_PERIOD : time := 8680 ns;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC:='0';
	signal reset : STD_LOGIC;
	signal module_adress : STD_LOGIC_VECTOR(7 downto 0):=x"03";
	signal data_input : STD_LOGIC_VECTOR(7 downto 0):=x"00";
	signal data_input_rdy : STD_LOGIC:='0';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal LsinA : STD_LOGIC_VECTOR(31 downto 0);
	signal LsinB : STD_LOGIC_VECTOR(31 downto 0); 
	signal coord_data_rdy : STD_LOGIC;
	signal command_output : STD_LOGIC_VECTOR(7 downto 0);
	signal command_rdy : STD_LOGIC;
	
	--входные сигналы uart приемника
	signal uart_in : STD_LOGIC:='1';

begin

	-- Unit Under Test port map
	UUT : packageparser
		port map (
			clk => clk,
			reset => reset,
			module_adress => module_adress,
			data_input => data_input,
			data_input_rdy => data_input_rdy,
			coord_data_rdy => coord_data_rdy,
			command_rdy => command_rdy,
			LsinA => LsinA,
			LsinB => LsinB,
			command_output => command_output
		);
		
--	UUT1 : rs_in
--	port map (	
--			clk => clk,
--			reset => reset,
--			uart_in => uart_in,
--			
--			data_out => data_input,
--			data_rdy => data_input_rdy
--	);	
--	
	
	clk	<= not clk after 5 ns;
process	is
begin  	  
	wait for 20 ns;
	if(clk = '1')then
		data_input_rdy <= '1';
		data_input <= x"3A";
		wait for 5 ns;
		data_input <= module_adress;
		wait for 5 ns;
		data_input <= x"00";
		wait for 5 ns;
		data_input <= x"08";
		wait for 5 ns;
		data_input <= x"22";
		wait for 5 ns;
		data_input <= x"12"; 
		wait for 5 ns;
		data_input <= x"34";
		wait for 5 ns;
		data_input <= x"56"; 
		wait for 5 ns;
		data_input <= x"78";
		wait for 5 ns;
		data_input <= x"11";
		wait for 5 ns;
		data_input <= x"80";
		wait for 5 ns;
		data_input <= x"00";  
		data_input_rdy <= '0';
	end if;
	
		
		assert false report "Finish." severity note;
end process;


end TB_ARCHITECTURE;


