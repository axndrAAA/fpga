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
-- Description : это ѕередающий модуль. ќн по команде data_in_rdy считывает данные со входной шины, и передает на выходной uart
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity uart_tx is
	port(
	clk			: in std_logic;  --100Mhz
	reset		: in std_logic;  -- 1 - 1-сброс всей системы(общий) 
	data_in		: in std_logic_vector(7 downto 0);-- 8 битна€ входна€ шина
	data_in_rdy	: in std_logic; -- 1- значит на data_in валидные данные и их можно считывать

	uart_out	: out std_logic -- выходной uart 8N1 115200
	);
end uart_tx;


architecture uart_tx of uart_tx is
begin

	 -- enter your statements here --

end uart_tx;
