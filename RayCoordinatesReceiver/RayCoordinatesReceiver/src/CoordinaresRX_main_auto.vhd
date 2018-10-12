-------------------------------------------------------------------------------
--
-- Title       : CoordinaresRX
-- Design      : RayCoordinatesReceiver
-- Author      : Alexander
-- Company     : MAI
--
-------------------------------------------------------------------------------
--
-- File        : F:\git\fpga\RayCoordinatesReceiver\RayCoordinatesReceiver\src\CoordinaresRX_main_auto.vhd
-- Generated   : Fri Oct 12 12:38:23 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : ќсновной блок. ќн слушает входной uart и воспринимает только свои команды а также мультикастные команды.
-- 					* ѕри приеме своей команды, он декодирует команду в посылке, вытаскивает числовые значени€ синусов углов, и выставл€ет все это на выходы
-- 				провер€€, при этом контрольную сумму.
--					* ѕри приеме мультикастной комманды происходит что-то...(нужно уточнить).
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity CoordinaresRX is
	 port(
		 clk : in STD_LOGIC; --  100 MHz
		 uart_in : in STD_LOGIC; -- входной uart 8N1 115200
		 reset : in STD_LOGIC; -- 1-сброс всей системы(общий)
		 adress : in BIT_VECTOR(7 downto 0); --адрес устройства
		 
		 coord_data_rdy : out STD_LOGIC; -- 1-когда на обоих шинах LsinA и LsinB установлены валидные данные
		 command_rdy : out STD_LOGIC; -- 1-когда на шине command_output сформирована и установлена валидна€ команда
		 LsinA : out STD_LOGIC_VECTOR(31 downto 0); -- 32х битна€ шина дл€ числового значени€ синуса угла ј отклонени€ луча 
		 LsinB : out STD_LOGIC_VECTOR(31 downto 0);	-- 32х битна€ шина дл€ числового значени€ синуса угла B отклонени€ луча 
		 command_output : out STD_LOGIC_VECTOR(7 downto 0) -- 8х битна€ шина дл€ комманды передаваемой затем в выходной uart.
	     );
end CoordinaresRX;

architecture CoordinaresRX of CoordinaresRX is
begin

	 -- enter your statements here --

end CoordinaresRX;
