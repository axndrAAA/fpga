-------------------------------------------------------------------------------
--
-- Title       : packageParser
-- Design      : RayCoordinatesReceiver
-- Author      : Alexander
-- Company     : MAI
--
-------------------------------------------------------------------------------
--
-- File        : e:\git\fpga\RayCoordinatesReceiver\RayCoordinatesReceiver\src\PackageParser.vhd
-- Generated   : Tue Oct 16 12:22:59 2018
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
--{entity {packageParser} architecture {packageParser}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity packageParser is	
	 port(
		 clk 			: in std_logic; --  100 MHz
		 reset 			: in std_logic; -- 1-сброс всей системы(общий)
		 module_adress 	: in std_logic_vector(7 downto 0); -- адрес устройства
		 data_input		: in std_logic_vector(7 downto 0);  -- входные данные от uart приемника
		 data_input_rdy : in std_logic; -- готовность данных на входе от uart приемника
		 
		 coord_data_rdy : out std_logic; -- 1-когда на обоих шинах LsinA и LsinB установлены валидные данные
		 command_rdy : out std_logic; -- 1-когда на шине command_output сформирована и установлена валидная команда
		 LsinA : out std_logic_vector(31 downto 0); -- 32х битная шина для числового значения синуса угла А отклонения луча 
		 LsinB : out std_logic_vector(31 downto 0);	-- 32х битная шина для числового значения синуса угла B отклонения луча 
		 command_output : out std_logic_vector(7 downto 0) -- 8х битная шина для комманды передаваемой затем в выходной uart.
	     );
end packageParser;

architecture packageParser of packageParser is
constant StartSymbol 		: std_logic_vector(7 downto 0):=x"3A"; -- стартовый символ посылки
constant multicastAddress 	: std_logic_vector(7 downto 0):=x"0E"; -- адрес для мультикастовой посылки 
constant commandCode		: std_logic_vector(7 downto 0):=x"22"; -- код комманды для данного модуля

	type stm_states is (
	   	--waitData, -- ожидание данных
		waitStartSymbol, -- считывание стартового символа посылки
		readModuleAdr, -- считывание адреса модуля из посылки
		readPackageBodySize, -- если был считан стартовый символ данного устройства
		multucastAdrRead, -- если был считан мультикастовый символ (15)
		readCommand, -- считываем  комманду
		readPackageBody, -- считываем тело пакета
		readReserveByte, --считываем резервный байт
		readCSByte, -- считываем байт контрольной суммы
		checkCS, -- считаем и проверяем контрольную сумму
		setData2Out, -- выставляем данные на выходы
		dataRdy_formAnsw -- валидные данные на выходе, формируем ответ
	);
	signal stm_parser		:	stm_states:= waitStartSymbol; -- переменная состояния конечного автомата
	signal input_message	:	std_logic_vector(103 downto 0); --входное сообщение
	signal recv_byte_count 	:	std_logic_vector(7 downto 0):=x"00"; -- счетчик считанных бит(используется для чтения многобитных полей)
	signal packageBodySize	: 	std_logic_vector(15 downto 0):=(others => '0'); -- размер посылки (считывается из команды на входе)
	signal isCorrectCommandRecv : std_logic:='0';
	signal CS_recv_byte 	:	std_logic_vector(7 downto 0):=x"00";  
	
function checkCSC ( message : in std_logic_vector;
					cs_recv	 : std_logic_vector
					) return boolean is
variable ret : std_logic_vector(7 downto 0):=(others=>'0');
variable tmp : std_logic_vector(7 downto 0);
begin
	-- TODO:
	-- здесь реализуется рассчет контрольной суммы
--	for i in 0 to 14 loop
--		tmp := message(103-i downto 95-i);
--		ret := ret + tmp;
--	end loop;
--	if(ret = cs_recv)then
--		return TRUE;
--	else
--		return FALSE;
--	end if;	
	return TRUE;
end function;

begin
	main_pr : process(clk)
	begin					
		if(rising_edge(clk))then
			if(reset = '1')then -- общий сброс системы
				stm_parser <= waitStartSymbol;
				coord_data_rdy <= '0';
				command_rdy <= '0';
				LsinA <= (others => '0');
				LsinB <= (others => '0');
				command_output <= (others => '0');
			end if;
			
			case stm_parser is
--				when waitStartSymbol => -- ожидаем прихода стартового символа
--					input_message <= (others => '0'); -- сбрасываем считанное сообщение
--					packageBodySize <= (others => '0'); -- обнуляем размер из считанного пакета	
--					coord_data_rdy <= '0'; -- сбрасываем в ноль все выходы
--					command_rdy <= '0';
--					LsinA <= (others => '0');
--					LsinB <= (others => '0');
--					command_output <= (others => '0');
--					if(data_input_rdy = '1')then
--						stm_parser <= waitStartSymbol;
--					end if;				
				when waitStartSymbol =>
					input_message <= (others => '0'); -- сбрасываем считанное сообщение
					packageBodySize <= (others => '0'); -- обнуляем размер из считанного пакета	
					coord_data_rdy <= '0'; -- сбрасываем в ноль все выходы
					command_rdy <= '0';
					LsinA <= (others => '0');
					LsinB <= (others => '0');
					command_output <= (others => '0');
					if(data_input_rdy = '1')then
						if(data_input = StartSymbol)then -- получен стартовый символ посылки, не записываем его в input_message
							stm_parser <= readModuleAdr; -- переходим к считыванию адреса модуля
						else 							 -- получен какой то мусор. 
							stm_parser <= waitStartSymbol; -- Возвращаемся к ожиданию стартового символа
						end if;						
					end if;
				
				when readModuleAdr =>
					if(data_input_rdy = '1')then
						if(data_input = module_adress)then -- считан адрес данного модуля
							input_message <= input_message(95 downto 0) & data_input; -- считываем байт в буфер
							stm_parser <= readPackageBodySize; -- переходим к считыванию команды
						elsif (data_input = multicastAddress)then -- получен общий адрес 
							input_message <= input_message(95 downto 0) & data_input; -- считываем байт в буфер
							stm_parser <= multucastAdrRead; -- переходим к считыванию общей команды 
						else 
							stm_parser <= waitStartSymbol; -- считан мусор -> возвращаемся к ожиданию стартового символа
						end if;
						recv_byte_count <= (others=> '0'); -- сбрасываем счетчик принятых байт
					end if;					
				
				when readPackageBodySize =>
				if(data_input_rdy = '1')then -- считываем размер пакета
						input_message <= input_message(95 downto 0) & data_input; -- считываем байт в буфер
						packageBodySize <= packageBodySize(7 downto 0) & data_input; -- считываем размер в отдельную переменную
						recv_byte_count <= recv_byte_count + 1;	
						
						if(recv_byte_count = 1)then	-- приняты оба байта размера посылки
						  	recv_byte_count <= (others=> '0');		-- сбрасываем счетчик принятых байт
						  	stm_parser <= readCommand; -- и переходим к считыванию комманд
						end if;
					end if;				
				when multucastAdrRead =>
					if(data_input_rdy = '1')then
						-- действия выполняемые при считывании общего адреса
					end if;
				when readCommand =>
					if(data_input_rdy = '1')then -- считываем комманду
					 	if(data_input = commandCode)then -- если принимаемая комманда содержит наш код, то считываем тело пакета
							 input_message <= input_message(95 downto 0) & data_input;
							 stm_parser <= readPackageBody;
						else
							stm_parser <= waitStartSymbol; -- комманда не наша, возвращаемся к ожиданию данных
						end if;	
					end if;				
				when readPackageBody => 
				if(data_input_rdy = '1')then -- считываем тело пакета (4 байта)
						input_message <= input_message(95 downto 0) & data_input; -- считываем байт в буфер
						recv_byte_count <= recv_byte_count + 1;	
						
						if(recv_byte_count = packageBodySize)then -- все байты тела пакета считаны идем дальше
							recv_byte_count <= (others=> '0');
							stm_parser <= readReserveByte;
						end if;
					end if;				
				when readReserveByte =>
					if(data_input_rdy = '1')then -- читаем резервный байт
						input_message <= input_message(95 downto 0) & data_input;
						stm_parser <= readCSByte;
					end if;				
				when readCSByte =>
					if(data_input_rdy = '1')then -- читаем байт контрольной суммы
						CS_recv_byte <= data_input;
						stm_parser <= readCSByte;
					end if;	 
				when checkCS =>
				   	if(TRUE)then --	checkCSC(input_message,CS_recv_byte)
						stm_parser <= setData2Out; -- проверка пройдена, выставляем данные на выход
					else
						stm_parser <= waitStartSymbol; -- контрольная сумма не верна, ожидаем новый пакет
					end if;					
				
				when setData2Out =>
					LsinB <= input_message(95 downto 64);
					LsinA <= input_message(63 downto 32);
				when dataRdy_formAnsw =>
					coord_data_rdy <= '1';				
				when others => 
					stm_parser <= waitStartSymbol;
				end case;
		end if;
	end process main_pr;


end packageParser;
