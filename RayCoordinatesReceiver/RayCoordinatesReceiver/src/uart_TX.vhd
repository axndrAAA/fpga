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
-- Description : ��� ���������� ������. �� �� ������� data_in_rdy ��������� ������ �� ������� ����, � �������� �� �������� uart
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity uart_tx is
	port(
	clk			: in std_logic;  --100Mhz
	reset		: in std_logic;  -- 1 - 1-����� ���� �������(�����) 
	data_in		: in std_logic_vector(7 downto 0);-- 8 ������ ������� ����
	data_in_rdy	: in std_logic; -- 1- ������ �� data_in �������� ������ � �� ����� ���������

	uart_out	: out std_logic -- �������� uart 8N1 115200
	);
end uart_tx;


architecture uart_tx of uart_tx is
begin

	 -- enter your statements here --

end uart_tx;
