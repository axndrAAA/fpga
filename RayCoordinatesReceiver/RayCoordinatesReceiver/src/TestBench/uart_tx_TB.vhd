library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity uart_tx_tb is
end uart_tx_tb;

architecture TB_ARCHITECTURE of uart_tx_tb is
	-- Component declaration of the tested unit
	component uart_tx
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		data_in : in STD_LOGIC_VECTOR(7 downto 0);
		data_in_rdy : in STD_LOGIC;
		uart_out : out STD_LOGIC );
	end component;
	component rs_in
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		uart_in : in STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR(7 downto 0);
		data_rdy : out STD_LOGIC
		);
	end component; 
	
	--Stimulus constants
	constant c_BIT_PERIOD : time := 8680 ns;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC:='1';
	signal reset : STD_LOGIC:='0';
	signal data_in : STD_LOGIC_VECTOR(7 downto 0);
	signal data_in_rdy : STD_LOGIC:='0';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal uart_tx_out : STD_LOGIC; 
	signal data_rx_out : STD_LOGIC_VECTOR(7 downto 0);	 
	signal data_rx_out_rdy : STD_LOGIC;	
	
	--оправляемое сообщение
	signal  test_msg : std_logic_vector(7 downto 0):= x"4C";
	signal msg_changed : STD_LOGIC:='0';
	
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

begin

	-- Unit Under Test port map

		UUT : uart_tx
		port map (
			clk => clk,
			reset => reset,
			data_in => data_in,
			data_in_rdy => data_in_rdy,
			uart_out => uart_tx_out
		);
	--uart_rx
		UUT1 : rs_in
		port map(
			clk => clk,
			reset => reset,
			uart_in => uart_tx_out,
			data_out => data_rx_out,
			data_rdy => data_rx_out_rdy	
		);
		

	-- Add your stimulus here ...
	clk	<= not clk after 5 ns; 
	process	is
	begin  	  
		wait for 2000 ns; 
		
--		data_in <= x"4C";
--		data_in_rdy <= '1';
		
		 for i in 0 to 5 loop
			if(reset = '0')then	 
				test_msg <= test_msg + '1';
				msg_changed <= not msg_changed;	 
				wait for 2000 ns;
				--отправляем новый бит
				data_in <= test_msg; 
				data_in_rdy <= '1';
				report "Отправлен байт " & to_string(test_msg) severity note;
				
				--ждем ответа
				wait on data_rx_out_rdy;
	    		if (data_rx_out = test_msg) then
      				report "Тест пройден. Принят корректный байт." & to_string(data_rx_out) severity note;
   				else
      				report "Тест не пройден. Принят не корректный байт. " & to_string(data_rx_out) severity note;
    			end if;
			else
				data_in <= (others => '0');	
			end if;			 
		end loop;		
		
		
		assert false report "Finish." severity note;
	end process;	
process		
begin  
   wait for 200000 ns;
   reset<= not reset after 5 ns;
end process;

end TB_ARCHITECTURE;


