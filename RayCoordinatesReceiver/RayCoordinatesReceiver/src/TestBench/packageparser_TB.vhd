library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
-- Add your library and packages declaration here ...
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

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
		
		command_output_rdy : out STD_LOGIC;
		LsinA : out STD_LOGIC_VECTOR(31 downto 0);
		LsinB : out STD_LOGIC_VECTOR(31 downto 0)
		);
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
	signal command_output_rdy : STD_LOGIC;
	
	--входные сигналы uart приемника
	signal uart_in : STD_LOGIC:='1';
	
	--файл с сообщением
	file file_bytes : text;
	-- процедура отправки данных по uart
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
	UUT : packageparser
		port map (
			clk => clk,
			reset => reset,
			module_adress => module_adress,
			data_input => data_input,
			data_input_rdy => data_input_rdy,
			command_output_rdy => command_output_rdy,
			LsinA => LsinA,
			LsinB => LsinB
		);
		
	UUT1 : rs_in
	port map (	
			clk => clk,
			reset => reset,
			uart_in => uart_in,
			
			data_out => data_input,
			data_rdy => data_input_rdy
	);	
	
	
	clk	<= not clk after 5 ns;
process	is 
    variable v_ILINE     : line;
    variable n_byte : std_logic_vector(7 downto 0);
    variable v_SPACE     : character;
begin
	-- время моделирования для одного сообщения 2100 us
	
	file_open(file_bytes, "input_bytes.txt",  read_mode);
	
	wait for 2000 ns;
	while not endfile(file_bytes) loop
			readline(file_bytes, v_ILINE);
			read(v_ILINE, n_byte);
			UART_WRITE_BYTE(n_byte, uart_in);--передача на вход uart
			report "Msg sent." severity note;
			--data_input <= n_byte;
--			data_input_rdy <= '1';	
		wait for 10 ns;
	end loop;	   
--	if(not endfile(file_bytes))then
--		data_input <= x"00";
--		data_input_rdy <= '0';
--	end if;
	
	wait for 20 ns;
	
	file_close(file_bytes);

		
		assert false report "Finish." severity note;
end process;


end TB_ARCHITECTURE;


