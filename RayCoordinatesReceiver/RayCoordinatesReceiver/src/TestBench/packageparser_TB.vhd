library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity packageparser_tb is
end packageparser_tb;

architecture TB_ARCHITECTURE of packageparser_tb is
	-- Component declaration of the tested unit
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

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC:='0';
	signal reset : STD_LOGIC;
	signal module_adress : STD_LOGIC_VECTOR(7 downto 0);
	signal data_input : STD_LOGIC_VECTOR(7 downto 0);
	signal data_input_rdy : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal coord_data_rdy : STD_LOGIC;
	signal command_rdy : STD_LOGIC;
	signal LsinA : STD_LOGIC_VECTOR(31 downto 0);
	signal LsinB : STD_LOGIC_VECTOR(31 downto 0);
	signal command_output : STD_LOGIC_VECTOR(7 downto 0);

	-- Add your code here ...

	
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
	clk	<= not clk after 5 ns;
process	is
begin  	  
		wait for 2000 ns; 

	-- Add your stimulus here ...	
		
		assert false report "Finish." severity note;
end process;


end TB_ARCHITECTURE;


