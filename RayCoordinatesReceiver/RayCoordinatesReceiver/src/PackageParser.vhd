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
-- Description : 	парсер и реализующий его основной автомат 
--
-------------------------------------------------------------------------------
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

		 command_output_rdy : out std_logic; -- 1-когда на на шинах LsinA, command_output и LsinB установлены валидные данные и можно формировать ответную команду
		 LsinA : out std_logic_vector(31 downto 0); -- 32х битная шина для числового значения синуса угла А отклонения луча 
		 LsinB : out std_logic_vector(31 downto 0);	-- 32х битная шина для числового значения синуса угла B отклонения луча 
		 command_output		: out std_logic_vector(7 downto 0)	-- сюда выставляется код комманды данного модуля
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
		read_check_CS_byte -- считываем байт контрольной суммы проверяем её. если правильно то сразу выставляем данные на выход
		--checkCS, -- считаем и проверяем контрольную сумму
		--setData2Out -- выставляем данные на выходы и формируем сигнал о формировании ответа 
	);
	signal stm_parser		:	stm_states:= waitStartSymbol; -- переменная состояния конечного автомата
	signal input_message	:	std_logic_vector(103 downto 0); --входное сообщение
	signal inp_command_code_buf : std_logic_vector(7 downto 0):=x"00"; -- буфер для считываемого кода команды
	signal inp_pack_body_buf : std_logic_vector(63 downto 0); -- буфер для считываемого тела пакета
	
	signal recv_byte_count 	:	std_logic_vector(7 downto 0):=x"00"; -- счетчик считанных бит(используется для чтения многобитных полей)
	signal packageBodySize	: 	std_logic_vector(15 downto 0):=(others => '0'); -- размер посылки (считывается из команды на входе)
	signal isCorrectCommandRecv : std_logic:='0';
	signal CS_recv_byte 	:	std_logic_vector(7 downto 0):=x"00";  
	signal cs_calc 	:	std_logic_vector(7 downto 0):=x"00";
	
begin
	main_pr : process(clk)
	begin					
		if(rising_edge(clk))then
			if(reset = '1')then -- общий сброс системы
				stm_parser <= waitStartSymbol;
				command_output_rdy <= '0';
				LsinA <= (others => '0');
				LsinB <= (others => '0');
				command_output <= (others => '0'); 
				recv_byte_count <= x"00";
				isCorrectCommandRecv <= '0';
			else			
			case stm_parser is			
				when waitStartSymbol =>
					command_output_rdy <= '0'; -- выход не готов
					cs_calc <= (others =>'0'); -- сброс подсчета контрольной суммы 
					--это не нужно, но для отладки будет
					LsinA <= (others => '0');
					LsinB <= (others => '0');
					command_output <= (others => '0');	
					--
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
							cs_calc <= cs_calc + data_input; -- прибавляем очередной байт к контрольной сумме
							stm_parser <= readPackageBodySize; -- переходим к считыванию команды
						elsif (data_input = multicastAddress)then -- получен общий адрес 
							input_message <= input_message(95 downto 0) & data_input; -- считываем байт в буфер
							cs_calc <= cs_calc + data_input; -- прибавляем очередной байт к контрольной сумме
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
						cs_calc <= cs_calc + data_input; -- прибавляем очередной байт к контрольной сумме
						recv_byte_count <= recv_byte_count + 1;	
						
						if(recv_byte_count = 1)then	-- приняты оба байта размера посылки
						  	recv_byte_count <= (others=> '0');		-- сбрасываем счетчик принятых байт
						  	stm_parser <= readCommand; -- и переходим к считыванию комманд
						end if;
					end if;				
				when multucastAdrRead =>
					if(data_input_rdy = '1')then
						-- действия выполняемые при считывании общего адреса
						stm_parser <= waitStartSymbol;
					end if;
				when readCommand =>
					if(data_input_rdy = '1')then -- считываем комманду
					 	if(data_input = commandCode)then -- если принимаемая комманда содержит наш код, то считываем тело пакета
							 input_message <= input_message(95 downto 0) & data_input;
							 inp_command_code_buf <= data_input; --считываем комманду в буфер
							 cs_calc <= cs_calc + data_input; -- прибавляем очередной байт к контрольной сумме
							 stm_parser <= readPackageBody;
						else
							stm_parser <= waitStartSymbol; -- комманда не наша, возвращаемся к ожиданию данных
						end if;	
					end if;				
				when readPackageBody => 
				if(data_input_rdy = '1')then -- считываем тело пакета (8 байт)
					input_message <= input_message(95 downto 0) & data_input; -- считываем байт в буфер
					inp_pack_body_buf <= input_message(55 downto 0) & data_input;
					cs_calc <= cs_calc + data_input; -- прибавляем очередной байт к контрольной сумме
						recv_byte_count <= recv_byte_count + 1;	
						
						if(recv_byte_count = (packageBodySize-1))then -- все байты тела пакета считаны идем дальше
							recv_byte_count <= (others=> '0');
							stm_parser <= readReserveByte;
						end if;
					end if;				
				when readReserveByte =>
					if(data_input_rdy = '1')then -- читаем резервный байт
						input_message <= input_message(95 downto 0) & data_input;
						cs_calc <= cs_calc + data_input; -- прибавляем очередной байт к контрольной сумме
						--stm_parser <= readCSByte;
						stm_parser <= read_check_CS_byte;
					end if;	
				when read_check_CS_byte =>
					if(data_input_rdy = '1')then -- читаем и сверяем байт контрольной суммы
						if(data_input = cs_calc)then -- если контрольная сумма верна, выставляем сигналы на выход
--							LsinA <= input_message(71 downto 40);
--							LsinB <= input_message(39 downto 8);
--							command_output <= commandCode;		 
							LsinA <= inp_pack_body_buf(63 downto 32);
							LsinB <= inp_pack_body_buf(31 downto 0);
							command_output <= commandCode;
							command_output_rdy <= '1'; -- посылаем команду на формирование ответа
							stm_parser <= waitStartSymbol;-- и переходим на исходную
						else
							stm_parser <= waitStartSymbol; -- контрольная сумма не верна, ожидаем новый пакет
						end if;
					end if;	 
				--when readCSByte =>
--					if(data_input_rdy = '1')then -- читаем байт контрольной суммы
--						CS_recv_byte <= data_input;
--						stm_parser <= checkCS;
--					end if;	 
--				when checkCS =>
--					if(cs_calc = CS_recv_byte)then --	проверяем КС
--						stm_parser <= setData2Out; -- проверка пройдена,
--					else
--						stm_parser <= waitStartSymbol; -- контрольная сумма не верна, ожидаем новый пакет
--					end if;					
--				
--				when setData2Out =>	--выставляем данные на выход
--					LsinA <= input_message(71 downto 40);--input_message(95 downto 64);
--					LsinB <= input_message(39 downto 8);
--					command_output <= commandCode;
--					command_output_rdy <= '1'; -- посылаем команду на формирование ответа
--					stm_parser <= waitStartSymbol;-- и переходим на исходную
				end case; 
				end if;
		end if;
	end process main_pr;


end packageParser;
