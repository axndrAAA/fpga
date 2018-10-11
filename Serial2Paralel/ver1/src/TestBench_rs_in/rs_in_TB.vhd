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
	signal reset : STD_LOGIC:= '0';
	signal uart_in : STD_LOGIC:='1';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal data_out : STD_LOGIC_VECTOR(7 downto 0);
	signal data_rdy : STD_LOGIC;
	signal test_out1	:  std_logic_vector(1 downto 0);   
	signal msg_changed : STD_LOGIC:='0'; 
	--signal rst : STD_LOGIC:= '0';
	
	--оправляемое сообщение
	signal  test_msg : std_logic_vector(7 downto 0):= x"4C";
	
function to_string ( a: std_logic_vector) return string is
	variable b : string (1 to a'length) := (others => NUL);
	variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
return b;
end function;

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
	reset	<= not reset after 300000 ns;
process is
begin

	wait for 2000 ns; 
	
----отправка сообщения 	 
--    UART_WRITE_BYTE(x"4C", uart_in);
----	wait for 20 ms;	     
--	
--	
---- проверка принятого сообщения	  
----	if(data_rdy = '1')then
----	end if;
--	    if (data_out = x"4C") then
--      		report "Тест пройден. Принят корректный байт" severity note;
--   		else
--      		report "Тест не пройден. Принят не корректный байт" severity note;
--    	end if;
	 
	 
	 for i in 0 to 5 loop
		test_msg(i) <= '1';
		msg_changed <= not msg_changed;	 
		wait for 2000 ns;
		UART_WRITE_BYTE(test_msg, uart_in);
		report "Отправлен байт " & to_string(test_msg) severity note;
	    if (data_out = test_msg) then
      		report "Тест пройден. Принят корректный байт " & to_string(data_out) severity note;
   		else
      		report "Тест не пройден. Принят не корректный байт " & to_string(data_out) severity note;
    	end if;
	 end loop; 
	 
	 
	 
	 assert false report "Тест завершен" severity note;
end process;

end TB_ARCHITECTURE;


