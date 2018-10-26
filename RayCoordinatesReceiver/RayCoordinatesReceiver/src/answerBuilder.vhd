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
use IEEE.numeric_std.ALL;

entity answBuild is
	port(
		 clk 			: in std_logic; --  100 MHz
		 reset 			: in std_logic; -- 1-сброс всей системы(общий)
		 adr 		: in STD_LOGIC_VECTOR(7 downto 0); -- адрес модуля (необходимо, чтобы он был выставлен всегда)
		 com_code 	: in STD_LOGIC_VECTOR(7 downto 0); -- код комманды (приходит из парсера пакета)
		 start		: in std_logic; -- запуск формирования ответа. При этом на остальных входах уже есть валидные данные
		 
		 data_out : out STD_LOGIC_VECTOR(7 downto 0); --8ми битная выходная шина
		 data_out_rdy : out STD_LOGIC -- готовность данных на выходе
	     );
end answBuild;


architecture answBuild of answBuild is 
	constant startSymbol 	: std_logic_vector(7 downto 0):=x"3A"; -- стартовый символ посылки 
	constant commandSize	: std_logic_vector(15 downto 0):=x"0002"; -- размер посылки (не уверен, что именно такой, но точно 2х байтовый 
	constant clk_1_byte_tx	: std_logic_vector(19 downto 0):=x"021D4"; -- число тактов за которое происходит отправка всего сообщения по uart на скорости 115200
<<<<<<< HEAD
	--constant msgSize		: integer := 6;
	constant msgSize 	: std_logic_vector(7 downto 0):=x"05";

	type stm_states is (
		waitData, -- ожидаем данные и сразу их читаем в message (код комманды), и разрешения на формирование ответа ( на этот момент уже сформированы первые 4 байта ответа)
		shiftDataToOutput, -- сдвигаем данные в message на 8 бит, и крайние выставляем на data_out
		transmitCS -- передаем контрольную сумму
		--transmit -- передаем данные на выходной блок
	);
	
	signal stm		:	stm_states:= waitData; -- переменная состояния конечного автомата 
	signal message	: std_logic_vector(39 downto 0):= (others => '0'); -- формируемое сообщени
	signal tx_byte_index 	:	integer range 0 to 7:=0; -- счетчик переданного байта
	signal clk_1_byte_tx_counter	: std_logic_vector(19 downto 0):=(others => '0'); -- счетчик ожидания до выставления на выход следующего байта
	signal cs_calc 	:	std_logic_vector(7 downto 0):=x"00"; -- сигнал для подсчета контрольной суммы

=======
	--constant msgSize		: integer := 6-1;
	--constant msgSize		: std_logic_vector(3 downto 0):=x"6";
	--constant ssymb_adr_packSz: std_logic_vector(31 downto 0):= startSymbol & adr & commandSize;

	type stm_states is (
		waitData, -- ожидаем данные и сразу их читаем буферы
		transmit_start_symbol, -- передаем стартовый символ
		transmit_module_adr, -- передаем адрес модуля
		transmit_command_size, --передаем размер комманды
		transmit_command, -- передаем комманду
		transmit_CS -- передаем байт контрольной суммы
		--formAnsw_addCS, -- формируем ответ. считаем и приписываем контрольную сумму
		--transmit_data, -- передаем данные на выходной блок(без байта контрольной суммы)
		--transmit_cs -- передаем сформированную контрольную сумму
	);
	
	signal stm		:	stm_states:= waitData; -- переменная состояния конечного автомата 
	--signal message	: std_logic_vector(47 downto 0):= (others => '0'); -- формируемое сообщени
	--signal tx_byte_index 	:	integer range 0 to 7:=0; -- счетчик переданного байта
	signal tx_byte_index 	:	std_logic_vector(4 downto 0):=(others => '0'); -- счетчик переданного байта
	signal adr_buf	: std_logic_vector(7 downto 0):= (others => '0'); -- буфер для адреса
	signal com_code_buf	: std_logic_vector(7 downto 0):= (others => '0'); -- буфер для комманды
	signal clk_1_byte_tx_counter	: std_logic_vector(19 downto 0):=(others => '0'); -- счетчик ожидания до выставления на выход следующего байта
	signal cs_calc 	:	std_logic_vector(7 downto 0):=x"00"; -- сигнал для подсчета контрольной суммы
	
>>>>>>> 04db91236edd4c62640423d6f7985e09c89f63fd
begin

main_pr:process(clk)
begin
	if(rising_edge(clk))then 
		if(reset = '1')then
			data_out <= (others => '0'); 
			tx_byte_index <= (others => '0');
			stm <= waitData;				
		else		 
		case stm is
			when waitData	=>	
				data_out_rdy <= '0';
<<<<<<< HEAD
				if(start = '1')then	  
					message <= startSymbol & adr & commandSize & com_code;
					clk_1_byte_tx_counter <= clk_1_byte_tx; -- это необходимо, для моментальной передачи первого байта
					stm <= shiftDataToOutput;
				end if;	
			when shiftDataToOutput => 
				data_out_rdy <= '0';
				if(tx_byte_index = msgSize)then
					tx_byte_index <= 0;
					stm <= transmitCS; -- если переданы все информационные байты передаем КС
				else
					if (clk_1_byte_tx_counter = clk_1_byte_tx)then
						message <= message(31 downto 0) & x"00";
						data_out <= message(39 downto 32);
						data_out_rdy <= '1'; 
						tx_byte_index <= tx_byte_index + 1;
						clk_1_byte_tx_counter <= x"00000";
					else
						clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
					end if;					
				end if;
			
			when transmitCS =>
				stm <= waitData;
			--when formAnsw_addCS => -- считаем и записываем контрольную сумму
--				message <= message(39 downto 0) & calcCS(message);
--				clk_1_byte_tx_counter <= clk_1_byte_tx; -- это необходимо, для моментальной передачи первого байта
--				stm <= transmit;
--			when transmit => -- передаем данные
--				data_out_rdy <= '0';
--				if(tx_byte_index = msgSize)then 											
--					tx_byte_index <= 0;
--					stm <= waitData; -- если переданы все байты возвращаемся на исходную 
--					else
--						if (clk_1_byte_tx_counter = clk_1_byte_tx)then
--							data_out <= message(8*(tx_byte_index + 1)-1 downto 8*tx_byte_index);
--							data_out_rdy <= '1'; 
--							tx_byte_index <= tx_byte_index + 1;
--							clk_1_byte_tx_counter <= x"00000";
--						else
--							clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
--						end if;					
--				end if;
=======
				if(start = '1')then	  												   
					adr_buf <= adr; -- записываем адрес в буфер
					com_code_buf <= com_code; -- и комманду
					clk_1_byte_tx_counter <= clk_1_byte_tx; -- это необходимо для моментальной передачи первого байта
					stm <= transmit_start_symbol;
				end if;			
			when transmit_start_symbol => -- передача стартового символа
				if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= startSymbol;	-- выставляем стартовый символ
				   data_out_rdy <= '1'; 
				   clk_1_byte_tx_counter <= x"00000"; -- сброс счетчика ожидания готовности uart_tx
				   stm <= transmit_module_adr;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;
			when transmit_module_adr =>	-- передача адреса модуля
				if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= adr_buf;	-- выставляем адрес модуля 
				   data_out_rdy <= '1'; 						   
				   cs_calc <= cs_calc + adr_buf; --подсчитываем контрольную сумму
				   clk_1_byte_tx_counter <= x"00000"; -- счетчик ожидания готовности uart_tx
				   stm <= transmit_command_size;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;	  
			when transmit_command_size =>
				data_out_rdy <= '0';
				if(tx_byte_index = 2)then 											
					tx_byte_index <= (others =>'0');
					stm <= transmit_command; -- если переданы все передаем комманду
				else
					if (clk_1_byte_tx_counter = clk_1_byte_tx)then 
						data_out <= commandSize(8*(to_integer(unsigned(tx_byte_index)) + 1)-1 downto 8*to_integer(unsigned(tx_byte_index))); -- выставляем на выход байт
						cs_calc <= cs_calc + commandSize(8*(to_integer(unsigned(tx_byte_index)) + 1)-1 downto 8*to_integer(unsigned(tx_byte_index))); -- считаем контрольную сумм
						data_out_rdy <= '1'; -- готовность очередного байта
						tx_byte_index <= tx_byte_index + 1; --счетчик байт
						clk_1_byte_tx_counter <= x"00000"; -- счетчик ожидания готовности uart_tx
					else
							clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
					end if;					
				end if;
				--stm <= transmit_command; 		
			when  transmit_command => -- передача кода команды
			   if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= com_code_buf;	-- выставляем код комманды
				   data_out_rdy <= '1'; 						   
				   cs_calc <= cs_calc + com_code_buf; --подсчитываем контрольную сумму
				   clk_1_byte_tx_counter <= x"00000"; -- сброс счетчика ожидания готовности uart_tx
				   stm <= transmit_CS;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;
			when transmit_CS =>	 -- передача контрольной суммы
				if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= cs_calc;	-- выставляем байт контрольной суммы
				   data_out_rdy <= '1'; 						   
				   cs_calc <= (others => '0'); -- сбрасываем контрольную сумму
				   clk_1_byte_tx_counter <= x"00000"; -- сброс счетчика ожидания готовности uart_tx
				   stm <= waitData;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;
--			when transmit_data => -- передаем данные
--				data_out_rdy <= '0';
--				if(tx_byte_index = msgSize)then 											
--					tx_byte_index <= (others =>'0');
--					stm <= transmit_cs; -- если переданы все передаем контрольную сумму
--				else
--					if (clk_1_byte_tx_counter = clk_1_byte_tx)then
--						if(not tx_byte_index = 0)then
--							cs_calc <= cs_calc + message(8*(tx_byte_index + 1)-1 downto 8*tx_byte_index); -- считаем контрольную сумму
--						end if;
--						data_out <= message(8*(tx_byte_index + 1)-1 downto 8*tx_byte_index); -- выставляем на выход очередной байт
--						data_out_rdy <= '1'; -- готовность очередного байта
--						tx_byte_index <= tx_byte_index + 1; --счетчик байт
--						clk_1_byte_tx_counter <= x"00000"; -- счетчик ожидания готовности uart_tx
--					else
--							clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
--					end if;					
--				end if;
--			when transmit_cs =>
--				stm <= waitData; -- переданы все байты возвращаемся на исходную
>>>>>>> 04db91236edd4c62640423d6f7985e09c89f63fd
		end case;
		end if;
	end if;
end process main_pr;

end answBuild;
