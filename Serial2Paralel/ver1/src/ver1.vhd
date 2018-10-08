-------------------------------------------------------------------------------
--
-- Title       : ver1
-- Design      : ver1
-- Author      : Alexander
-- Company     : MAI
--
-------------------------------------------------------------------------------
--
-- File        : f:\git\fpga\Serial2Paralel\ver1\src\ver1.vhd
-- Generated   : Fri Oct  5 00:26:40 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {ver1} architecture {ver1}}

library IEEE;
use IEEE.std_logic_1164.all;

entity ver1 is 
	port(
	clk		: in std_logic;  --100Mhz
	reset	: in std_logic;  -- 1 - reset
	uart_in : in std_logic;
	data_out : out std_logic_vector(7 downto 0);
	data_rdy : out std_logic); -- 1 - ready
	
end ver1;

--}} End of automatically maintained section

architecture ver1 of ver1 is	

signal clk_pulse_counter: integer:= 0;			 -- счетчик для отсчета импульсов тактового входа и обнаружения "середины" бита
signal rx_prev: std_logic:= '1';					     -- предыдущий бит на входе
signal rx_flag: std_logic :='0';
signal bit_counter: integer range 0 to 9:=0;-- счетчик принятых бит

begin
	
main_pr: process(clk)	 
variable bit_counter: integer range 0 to 9:=0;-- счетчик принятых бит

begin		
	if(rising_edge(clk))then 
			-- обнаружение стартового бита
			if(uart_in = '0' and rx_prev = '1')then
				-- старт
				rx_prev <= '0';
				rx_flag <= '1';
			else		
				-- не старт
				rx_prev <= uart_in;
			end if;	 
	
			-- если прошло более половины длительности бита, 
			-- то это начало посылки. Начиинаем считываетние.
			if( clk_pulse_counter > 500)then   
				case(bit_counter) is
					when 0 =>
						if(uart_in = '0')then 
							-- стартовый бит
							bit_counter := 1;
						else
							bit_counter:= 0; 
							rx_flag <='0';
						end if;
					when 1 =>
						data_out(0) <= uart_in;	 
						bit_counter:= bit_counter + 1; -- 2
					when 2 => 							   
						data_out(1) <= uart_in;	 
						bit_counter:= bit_counter + 1;						
					when 3 =>						  
						data_out(2) <= uart_in;	 
						bit_counter:= bit_counter + 1;
					when 4 =>						  
						data_out(3) <= uart_in;	 
						bit_counter:= bit_counter + 1;
					when 5 =>						  
						data_out(4) <= uart_in;	 
						bit_counter:= bit_counter + 1;
					when 6 =>
						data_out(5) <= uart_in;	 
						bit_counter:= bit_counter + 1;
					when 7 =>
						data_out(6) <= uart_in;	 
						bit_counter:= bit_counter + 1;
					when 8 =>
						data_out(7) <= uart_in;	 
						bit_counter:= bit_counter + 1;
					when 9 =>
						rx_flag <= '0';
						if(uart_in = '1')then
							data_rdy <= '1';
						end if;
						
					
				
				end case;
			end if;
	end if;
	
	
	
end process;


clk_counter: process(clk)
begin
	
	
	if(rising_edge(clk))then 
		if(rx_flag = '1')then
			clk_pulse_counter<= clk_pulse_counter + 1;
		else
			clk_pulse_counter<= 0;
		end if;	
	end if;
end process;

end ver1;
