-------------------------------------------------------------------------------
--
-- Title       : answBuild
-- Design      : RayCoordinatesReceiver
-- Author      : Alexander
-- Company     : MAI
--
-------------------------------------------------------------------------------
--
-- File        : e:\git\fpga\RayCoordinatesReceiver\RayCoordinatesReceiver\src\answerBuilder.vhd
-- Generated   : Fri Oct 19 14:10:56 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 	модуль формироует ответ по линии uart
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;   
use IEEE.STD_LOGIC_unsigned.all;

entity answBuild is
	port(
		 clk 			: in std_logic; --  100 MHz
		 reset 			: in std_logic; -- 1-сброс всей системы(общий)
		 adr 		: in STD_LOGIC_VECTOR(7 downto 0); -- адрес модул€ (необходимо, чтобы он был выставлен всегда)
		 com_code 	: in STD_LOGIC_VECTOR(7 downto 0); -- код комманды (приходит из парсера пакета)
		 start		: in std_logic; -- запуск формировани€ ответа. ѕри этом на остальных входах уже есть валидные данные
		 
		 data_out : out STD_LOGIC_VECTOR(7 downto 0); --8ми битна€ выходна€ шина
		 data_out_rdy : out STD_LOGIC -- готовность данных на выходе
	     );
end answBuild;


architecture answBuild of answBuild is 
	constant startSymbol 	: std_logic_vector(7 downto 0):=x"3A"; -- стартовый символ посылки 
	constant commandSize	: std_logic_vector(15 downto 0):=x"0002"; -- размер посылки (не уверен, что именно такой, но точно 2х байтовый 
	constant clk_1_byte_tx	: std_logic_vector(19 downto 0):=x"021D4"; -- число тактов за которое происходит отправка всего сообщени€ по uart на скорости 115200
	constant msgSize 	: std_logic_vector(7 downto 0):=x"05";

	type stm_states is (
		waitData, -- ожидаем данные и сразу их читаем в message (код комманды), и разрешени€ на формирование ответа ( на этот момент уже сформированы первые 4 байта ответа)
		shiftDataToOutput, -- сдвигаем данные в message на 8 бит, и крайние выставл€ем на data_out
		transmitCS -- передаем контрольную сумму
	);
	
	signal stm		:	stm_states:= waitData; -- переменна€ состо€ни€ конечного автомата 
	signal message	: std_logic_vector(39 downto 0):= (others => '0'); -- формируемое сообщени
	signal tx_byte_index 	:	integer range 0 to 7:=0; -- счетчик переданного байта
	signal clk_1_byte_tx_counter	: std_logic_vector(19 downto 0):=(others => '0'); -- счетчик ожидани€ до выставлени€ на выход следующего байта
	signal cs_calc 	:	std_logic_vector(7 downto 0):=x"00"; -- сигнал дл€ подсчета контрольной суммы

begin

main_pr:process(clk)
begin
	if(rising_edge(clk))then 
		if(reset = '1')then
			data_out <= (others => '0');
			data_out_rdy <= '0';
			tx_byte_index <= 0;
			stm <= waitData;				
		else		 
		case stm is
			when waitData	=>	
				data_out_rdy <= '0';
				if(start = '1')then
					cs_calc <= x"00";
					message <= startSymbol & adr & commandSize & com_code;
					clk_1_byte_tx_counter <= clk_1_byte_tx; -- это необходимо, дл€ моментальной передачи первого байта
					stm <= shiftDataToOutput;
				end if;	
			when shiftDataToOutput => 
				data_out_rdy <= '0';
				if(tx_byte_index = msgSize)then
					tx_byte_index <= 0;
					stm <= transmitCS; -- если переданы все информационные байты передаем  —
				else
					if (clk_1_byte_tx_counter = clk_1_byte_tx)then
						message <= message(31 downto 0) & x"00";
						data_out <= message(39 downto 32);
						if(tx_byte_index /= 0)then  -- подсчет контрольной суммы( включет все байты кроме стартового символа
							cs_calc <= cs_calc + message(39 downto 32);
						end if;						
						data_out_rdy <= '1'; 
						tx_byte_index <= tx_byte_index + 1;
						clk_1_byte_tx_counter <= x"00000";
					else
						clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
					end if;					
				end if;
			
			when transmitCS => -- передаем контрольную сумму
				if (clk_1_byte_tx_counter = clk_1_byte_tx)then -- отсчитываем задержку
						data_out <= cs_calc;					
						data_out_rdy <= '1'; 
						clk_1_byte_tx_counter <= x"00000";
						stm <= waitData;
				else
						clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
				end if;
		end case;
		end if;
	end if;
end process main_pr;

end answBuild;
