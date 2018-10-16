-------------------------------------------------------------------------------
--
-- Title       : uart_tx
-- Design      : RayCoordinatesReceiver
-- Author      : Alexander
-- Company     : MAI
--
-------------------------------------------------------------------------------
--
-- File        : F:\git\fpga\RayCoordinatesReceiver\RayCoordinatesReceiver\src\uart_tx.vhd
-- Generated   : Fri Oct 12 12:10:36 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : это Передающий модуль. Он по команде data_in_rdy считывает данные со входной шины, и передает на выходной uart
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
entity uart_tx is
	port(
	clk			: in std_logic;  --100Mhz
	reset		: in std_logic;  -- 1 - 1-сброс всей системы(общий) 
	data_in		: in std_logic_vector(7 downto 0);-- 8 битная входная шина
	data_in_rdy	: in std_logic; -- 1- значит на data_in валидные данные и их можно считывать

	uart_out	: out std_logic -- выходной uart 8N1 115200
	);
end uart_tx;


architecture uart_tx of uart_tx is	
	constant clk_per_bit	: std_logic_vector(15 downto 0):=x"0361"; -- число тактов на каждый бит
	type stm_states is (
		waitData, -- начальное состояние. Ожидание данных на входе
		buferingData, -- сохранение данных на входной шине во внутренний буфер
		txStartBit, -- передача стартового бита
		txData, -- передача данных 
		txStopBit -- передача стопового бита
	);
	
	signal st_main			:	stm_states:= waitData; -- переменная состояния конечного автомата
	signal tx_bit_index 	:	integer range 0 to 7:=0; -- счетчик переданного бита
	signal input_data_bufer	: 	std_logic_vector(7 downto 0):=(others => '0'); -- входной буфер
	signal clk_bit_counter	: 	std_logic_vector(15 downto 0); -- счетчик отсчета тактового сигнала при передаче бита  
	
	
begin
  	main_pr : process(clk) 
	  begin
	  	if (rising_edge(clk)) then
			if(reset = '1')  then
				st_main	<= waitData;
			end if;
			
			case st_main is				
				when waitData => -- режим ожидания данных на входе
					uart_out <= '1'; --	подтягиваем выход к логической 1   
					tx_bit_index <= 0; -- обнуляем счетчик переданных бит
					if (data_in_rdy = '1')then -- если на входной шине есть валидные данные
						st_main <= buferingData; -- переходим к буферизации данных
					end if;	

				when buferingData =>
					input_data_bufer <= data_in;
					st_main <= txStartBit;
					clk_bit_counter <=(others=>'0'); -- обнуляем счетчик
				when txStartBit =>
					uart_out <= '0'; -- устанавливаем лог.0 на выход
					if(clk_bit_counter < clk_per_bit)then -- отсчитываем длительность бита
						clk_bit_counter <= clk_bit_counter + '1';
					else
						clk_bit_counter <=(others=>'0');-- если отсчитали, сбрасываем счетчик, и
						st_main <= txData; -- переходим к передаче битов данных
					end if;
				when txData => 
					uart_out <= input_data_bufer(tx_bit_index); -- записываем передаваемый бит на выходную линию
					if(clk_bit_counter < clk_per_bit)then -- отсчитываем длительность бита 
						clk_bit_counter <= clk_bit_counter + '1';
					else 					
						clk_bit_counter <=(others=>'0');-- если отсчитали, сбрасываем счетчик
						if (tx_bit_index < 7)then -- и проверяем не закончена ли передача посылки
							tx_bit_index <=	 tx_bit_index + 1; -- если не закончена, переходим к передаче следующего бита
						else
							st_main <= txStopBit; -- если закончена, переходим к передаче стопового бита
						end if;	
					end if;
				
				when txStopBit =>
					uart_out <= '1';
					if(clk_bit_counter < clk_per_bit)then -- отсчитываем длительность бита
						clk_bit_counter <= clk_bit_counter + '1';
					else
						clk_bit_counter <=(others=>'0');-- если отсчитали, сбрасываем счетчик
						st_main <= waitData; -- и переходим к ожиданию следующей посылки
					end if;							
				when others => 
					st_main <= waitData;
				end case;
		end if;		  
	end process main_pr;   
		

end uart_tx;
