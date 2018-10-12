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
-- Description : �������� ����. �� ������� ������� uart � ������������ ������ ���� ������� � ����� ������������� �������.
-- 					* ��� ������ ����� �������, �� ���������� ������� � �������, ����������� �������� �������� ������� �����, � ���������� ��� ��� �� ������
-- 				��������, ��� ���� ����������� �����.
--					* ��� ������ ������������� �������� ���������� ���-��...(����� ��������).
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity CoordinaresRX is
	 port(
		 clk : in STD_LOGIC; --  100 MHz
		 uart_in : in STD_LOGIC; -- ������� uart 8N1 115200
		 reset : in STD_LOGIC; -- 1-����� ���� �������(�����)
		 adress : in BIT_VECTOR(7 downto 0); --����� ����������
		 
		 coord_data_rdy : out STD_LOGIC; -- 1-����� �� ����� ����� LsinA � LsinB ����������� �������� ������
		 command_rdy : out STD_LOGIC; -- 1-����� �� ���� command_output ������������ � ����������� �������� �������
		 LsinA : out STD_LOGIC_VECTOR(31 downto 0); -- 32� ������ ���� ��� ��������� �������� ������ ���� � ���������� ���� 
		 LsinB : out STD_LOGIC_VECTOR(31 downto 0);	-- 32� ������ ���� ��� ��������� �������� ������ ���� B ���������� ���� 
		 command_output : out STD_LOGIC_VECTOR(7 downto 0) -- 8� ������ ���� ��� �������� ������������ ����� � �������� uart.
	     );
end CoordinaresRX;

architecture CoordinaresRX of CoordinaresRX is
begin

	 -- enter your statements here --

end CoordinaresRX;
