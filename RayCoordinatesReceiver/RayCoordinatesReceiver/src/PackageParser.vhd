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
constant multicastAddress 	: std_logic_vector(7 downto 0):=x"15"; -- адрес для мультикастовой посылки

	type stm_states is (
	   	waitData, -- ожидание данных
		readStartSymbol, -- считывание стартового символа посылки
		readModuleAdr, -- считывание адреса модуля из посылки
		specAdrRead, -- если был считан стартовый символ данного устройства
		multucastAdrRead -- если был считан мультикастовый символ (15)
	);
	signal stm_parser	:	stm_states:= waitData; -- переменная состояния конечного автомата






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
					if(data_input_rdy = '1')then
						stm_parser <= readStartSymbol;
					end if;				
				when readStartSymbol =>
					if(data_input_rdy = '1')then
						if(data_input = StartSymbol)then -- получен стартовый символ посылки
							stm_parser <= readModuleAdr; -- переходим к считыванию адреса модуля
						else 							 -- получен какой то мусор. 
							stm_parser <= waitData; -- Возвращаемся к ожиданию стартового символа
						end if;						
					end if;
				
				when readModuleAdr =>
					if(data_input_rdy = '1')then
						if(data_input = module_adress)then -- считан адрес данного модуля
							stm_parser <= specAdrRead; -- переходим к считыванию команды
						elsif (data_input = multicastAddress) -- получен общий адрес 
							stm_parser <= multucastAdrRead; -- переходим к считыванию общей команды 
						else 
							stm_parser <= waitData; -- считан мусор -> возвращаемся к ожиданию стартового символа
						end if;						
					end if;					
				
				when specAdrRead =>
				
				when multucastAdrRead =>
				
				when others => 
					stm_parser <= waitData;
				end case;
		end if;
	end process main_pr;


end packageParser;
