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
	   	waitData, -- ожидание данных
		readStartSymbol, -- считывание стартового символа посылки
		readModuleAdr, -- считывание адреса модуля из посылки
		specAdrRead, -- если был считан стартовый символ данного устройства
		multucastAdrRead, -- если был считан мультикастовый символ (15)
		readCommand, -- считываем  комманду
		readPackageBody, -- считываем тело пакета
		readReserveByte, --считываем резервный байт
		readCSByte -- считываем байт контрольной суммы
	);
	signal stm_parser		:	stm_states:= waitData; -- переменная состояния конечного автомата
	signal input_message	:	std_logic_vector(119 downto 0); --входное сообщение
	signal recv_byte_count 	:	std_logic_vector(7 downto 0):=x"00"; -- счетчик считанных бит(используется для чтения многобитных полей)
	signal packageBodySize	: 	std_logic_vector(15 downto 0):=(others => '0'); -- размер посылки (считывается из команды на входе)
	signal isCorrectCommandRecv : std_logic:='0';




begin
	main_pr : process(clk)
	begin					
		if(rising_edge(clk))then
			if(reset = '1')then -- общий сброс системы
				stm_parser <= waitData;
				coord_data_rdy <= '0';
				command_rdy <= '0';
				LsinA <= (others => '0');
				LsinB <= (others => '0');
				command_output <= (others => '0');
			end if;
			
			case stm_parser is
				when waitdata => -- ожидаем прихода стартового символа
					input_message <= (others => '0'); -- сбрасываем считанное сообщение
					packageBodySize <= (others => '0'); -- обнуляем размер из считанного пакета
					if(data_input_rdy = '1')then
						stm_parser <= readStartSymbol;
					end if;				
				when readStartSymbol =>
					if(data_input_rdy = '1')then
						if(data_input = StartSymbol)then -- получен стартовый символ посылки 
							input_message <= input_message(111 downto 0) & data_input; -- считываем байт в буфер
							stm_parser <= readModuleAdr; -- переходим к считыванию адреса модуля
						else 							 -- получен какой то мусор. 
							stm_parser <= waitData; -- Возвращаемся к ожиданию стартового символа
						end if;						
					end if;
				
				when readModuleAdr =>
					if(data_input_rdy = '1')then
						if(data_input = module_adress)then -- считан адрес данного модуля
							input_message <= input_message(111 downto 0) & data_input; -- считываем байт в буфер
							stm_parser <= specAdrRead; -- переходим к считыванию команды
						elsif (data_input = multicastAddress)then -- получен общий адрес 
							input_message <= input_message(111 downto 0) & data_input; -- считываем байт в буфер
							stm_parser <= multucastAdrRead; -- переходим к считыванию общей команды 
						else 
							stm_parser <= waitData; -- считан мусор -> возвращаемся к ожиданию стартового символа
						end if;
						recv_byte_count <= (others=> '0'); -- сбрасываем счетчик принятых байт
					end if;					
				
				when specAdrRead =>
					if(data_input_rdy = '1')then -- считываем размер пакета
						if( recv_byte_count = 2)then -- приняты оба байта размера посылки
						  	recv_byte_count <= (others=> '0');		-- сбрасываем счетчик принятых байт
						  	stm_parser <= readCommand; -- и переходим к считыванию комманды
						else
							input_message <= input_message(111 downto 0) & data_input; -- считываем байт в буфер
							packageBodySize <= packageBodySize(7 downto 0) & data_input; -- считываем размер в отдельную переменную
							recv_byte_count <= recv_byte_count + 1;
						end if;

					end if;				
				when multucastAdrRead =>
					if(data_input_rdy = '1')then
						-- действия выполняемые при считывании общего адреса
					end if;
				when readCommand =>
					if(data_input_rdy = '1')then -- считываем комманду
					 	if(data_input = commandCode)then -- если принимаемая комманда содержит наш код, то считываем тело пакета
							 input_message <= input_message(111 downto 0) & data_input;
							 stm_parser <= readPackageBody;
						else
							stm_parser <= waitData; -- комманда не наша, возвращаемся к ожиданию данных
						end if;	
					end if;				
				when readPackageBody => -- считываем тело пакета (4 байта)
					if(data_input_rdy = '1')then
						if(recv_byte_count = packageBodySize)then -- все байты тела пакета считаны
							recv_byte_count <= (others=> '0');
							stm_parser <= readReserveByte;
						else
							input_message <= input_message(111 downto 0) & data_input; -- считываем байт в буфер
							recv_byte_count <= recv_byte_count + 1;
						end if;
					end if;				
				when readReserveByte =>
				
				when readCSByte =>
				
				when others => 
					stm_parser <= waitData;
				end case;
		end if;
	end process main_pr;


end packageParser;
