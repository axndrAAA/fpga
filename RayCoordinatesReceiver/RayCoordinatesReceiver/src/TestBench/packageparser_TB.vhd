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
		LsinB : out STD_LOGIC_VECTOR(31 downto 0);
		command_output		: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component answBuild 
	port(
		 clk 			: in std_logic; 
		 reset 			: in std_logic; 
		 adr 		: in STD_LOGIC_VECTOR(7 downto 0);
		 com_code 	: in STD_LOGIC_VECTOR(7 downto 0);
		 start		: in std_logic; 	
		 
		 data_out : out STD_LOGIC_VECTOR(7 downto 0);
		 data_out_rdy : out STD_LOGIC
	     );
	end component; 
	
	component uart_tx
	port(
		clk			: in std_logic;
		reset		: in std_logic; 
		data_in		: in std_logic_vector(7 downto 0);
		data_in_rdy	: in std_logic;

		uart_out	: out std_logic
	);
	end component;

	constant c_BIT_PERIOD : time := 8680 ns;
	constant byte_delay : time := 75 us;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC:='0';
	signal reset : STD_LOGIC:='0';
	signal module_adress : STD_LOGIC_VECTOR(7 downto 0):=x"03";
	signal data_input : STD_LOGIC_VECTOR(7 downto 0):=x"00";
	signal data_input_rdy : STD_LOGIC:='0';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal LsinA : STD_LOGIC_VECTOR(31 downto 0);
	signal LsinB : STD_LOGIC_VECTOR(31 downto 0); 
	signal command_output : STD_LOGIC_VECTOR(7 downto 0);
	signal command_output_rdy : STD_LOGIC; 
	--выходы answerBuilder
	signal ab_data_out :  STD_LOGIC_VECTOR(7 downto 0);
	signal ab_data_out_rdy :  STD_LOGIC;
	--выходы uart приемника
	signal uart_out	: std_logic; 	
	--входной сигнал uart приемника
	signal uart_in : STD_LOGIC:='1';
	
	-- сигналы с выходного тестового uart приемника
	signal test_uart_out :  STD_LOGIC_VECTOR(7 downto 0);
	signal test_uart_out_rdy:  STD_LOGIC; 
	-- сигнал тестового входного uart_ передатчика
	signal uart_test_input :  STD_LOGIC_VECTOR(7 downto 0);
	signal uart_test_input_rdy:  STD_LOGIC; 
	
	--файл с сообщением
	file file_bytes : text;
--	-- процедура отправки данных по uart
--	procedure UART_WRITE_BYTE (
--    	i_data_in       : in  std_logic_vector(7 downto 0);
--    	signal o_serial : out std_logic) is
-- 	begin 
--    	-- Send Start Bit
--    	o_serial <= '0';
--    	if(reset = '1')then
--			return;
--		else
--			wait for c_BIT_PERIOD;
--		end if;
--		--wait for c_BIT_PERIOD;
--    	-- Send Data Byte
--    	for ii in 0 to 7 loop
--      		o_serial <= i_data_in(ii);
--    	if(reset = '1')then
--			return;
--		else
--			wait for c_BIT_PERIOD;
--		end if;
--		--wait for c_BIT_PERIOD;
--    	end loop;  -- ii
--    	-- Send Stop Bit
--    	o_serial <= '1';
--    	if(reset = '1')then
--			return;
--		else
--			wait for c_BIT_PERIOD;
--		end if;	   
--	--wait for c_BIT_PERIOD;
--  	end UART_WRITE_BYTE;

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
			LsinB => LsinB,
			command_output =>command_output
		);
		
	UUT1 : rs_in
	port map (	
			clk => clk,
			reset => reset,
			uart_in => uart_in,
			
			data_out => data_input,
			data_rdy => data_input_rdy
	);	
	
	UUT2 : answBuild
	port map (
			clk => clk,
			reset => reset,
			adr => module_adress,
		 	com_code => command_output,
		 	start => command_output_rdy,		 
		 	data_out => ab_data_out,
		 	data_out_rdy => ab_data_out_rdy
	);
	
	UUT3 : uart_tx
	port map (
			clk => clk,
			reset => reset,
			data_in	=> 	ab_data_out,
			data_in_rdy	=> ab_data_out_rdy,
			uart_out => uart_out
	);
	
	UUT4 : rs_in -- тестовый uart приемник
	port map (
			clk => clk,
			reset => reset,
			uart_in => uart_out,
			
			data_out => test_uart_out,
			data_rdy => test_uart_out_rdy
	); 
	
	UUT5 : uart_tx -- тесстовый uart передатчик
	port map (
			clk => clk,
			reset => reset,
			data_in	=> 	uart_test_input,
			data_in_rdy	=> uart_test_input_rdy,
			
			uart_out => uart_in
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
	if(reset = '0')then		
		module_adress <= x"03";
			readline(file_bytes, v_ILINE);
			read(v_ILINE, n_byte);
			uart_test_input <= n_byte;
			uart_test_input_rdy <= '1';
			wait for 10 ns;
			uart_test_input_rdy <= '0';
			report "Msg sent." severity note;
			wait for byte_delay*2;			
	else
		file_close(file_bytes);
		file_open(file_bytes, "input_bytes.txt",  read_mode);
	end if;
	end loop;	
	
	wait for 20 ns;
	file_close(file_bytes);
	
	assert false report "Finish." severity note;
end process;   

--process		
--begin  
--   wait for 2270 us;
--   
--   reset<='1','0' after 50 ns;
--
--end process;

end TB_ARCHITECTURE;


