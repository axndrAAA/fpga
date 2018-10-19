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
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {answBuild} architecture {answBuild}}

library IEEE;
use IEEE.std_logic_1164.all;   
use IEEE.STD_LOGIC_unsigned.all;

entity answBuild is
	port(
		 clk 			: in std_logic; --  100 MHz
		 reset 			: in std_logic; -- 1-сброс всей системы(общий)
		 adr 		: in STD_LOGIC_VECTOR(7 downto 0); -- адрес модуля
		 com_code 	: in STD_LOGIC_VECTOR(7 downto 0); -- код комманды (приходит из парсера пакета)
		 start		: in std_logic; -- запуск формирования ответа. При этом на остальных входах уже есть валидные данные
		 transmitter_rdy	: in std_logic; 	-- флаг отправки очередного сообщения 
		 
		 data_out : out STD_LOGIC_VECTOR(7 downto 0); --8ми битная выходная шина
		 data_out_rdy : out STD_LOGIC -- готовность данных на выходе
	     );
end answBuild;


architecture answBuild of answBuild is 
	constant startSymbol 	: std_logic_vector(7 downto 0):=x"3A"; -- стартовый символ посылки 
	constant commandSize	: std_logic_vector(15 downto 0):=(others => '0'); -- размер посылки (не уверен, что именно такой, но точно 2х байтовый 
	constant msgSize		: integer := 7;

	type stm_states is (
		waitStart, -- ожидаем данных, и разрешения на формирование ответа
		formAnsw_addSS, -- формируем ответ. записываем стартовый символ
		formAnsw_addAdr, -- формируем ответ.
		formAnsw_addSize, -- формируем ответ.
		formAnsw_addCommCode, -- формируем ответ.
		formAnsw_addCS, -- формируем ответ. считаем и приписываем контрольную сумму
		transmit -- передаем данные на выходной блок
	);
	
	signal stm		:	stm_states:= waitStart; -- переменная состояния конечного автомата 
	signal message	: std_logic_vector(47 downto 0):= (others => '0'); -- формируемое сообщени
	signal tx_bit_index 	:	integer range 0 to 7:=0; -- счетчик переданного байта
	
function calcCS ( message : in std_logic_vector(47 downto 0) ) return std_logic_vector is	
begin 
	-- TODO:
	-- здесь реализуется рассчет контрольной суммы
	return x"AE";
end function;

begin

main_pr:process(clk)
begin
	if(rising_edge(clk))then 
		if(reset = '1')then
			data_out <= (others => '0');
			data_out_rdy <= '0';
			stm <= waitStart;				
		end if;				 

		case stm is
			when waitStart	=>	
				data_out <= (others => '0');
				data_out_rdy <= '0';
				if(start = '1')then
					stm <= formAnsw_addSS;
				end if;			
			when formAnsw_addSS => --записываем стартовый символ (лучше будет исключить эту операцию, стартовый символ, адрес модуля и размер пакета лучше записывать по умолчанию) 
				message <= message(39 downto 0) & startSymbol;
				stm <= formAnsw_addAdr;			
			when formAnsw_addAdr =>	-- записываем адрес модуля
				message <= message(39 downto 0) & adr;
				stm <= formAnsw_addSize;
			when formAnsw_addSize =>  -- записываем размер посылки
				message <= message(31 downto 0) & commandSize;
				stm <= formAnsw_addCommCode;
			when formAnsw_addCommCode =>  -- записываем адрес команды 
				message <= message(39 downto 0) & com_code;
				stm <= formAnsw_addCS;
			when formAnsw_addCS => -- считаем и записываем контрольную сумму
				message <= message(39 downto 0) & calcCS(message);
			when transmit => -- передаем данные
				data_out_rdy <= '0';
				if(tx_bit_index = msgSize)then 
					stm <= waitStart; -- если переданы все байты возвращаемся на исходную
				elsif(transmitter_rdy = '1')then
					data_out <= message(47-(tx_bit_index*8) downto 47-((tx_bit_index+1)*8));
					data_out_rdy <= '1'; 
					tx_bit_index <= tx_bit_index + 1;
				end if;

			when others =>
				stm <= waitStart;
		end case;
		
		
	end if;

end process main_pr;

end answBuild;
