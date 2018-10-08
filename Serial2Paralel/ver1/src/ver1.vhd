-------------------------------------------------------------------------------
--
-- Title       : ver1
-- Design      : ver1
-- Author      : Alexander
-- Company     : MAI
--
-------------------------------------------------------------------------------
--
-- File        : f:\git\fpga\Serial2Paralel\ver1\src\ver1.vhd
-- Generated   : Fri Oct  5 00:26:40 2018
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
--{entity {ver1} architecture {ver1}}

library IEEE;
use IEEE.std_logic_1164.all;

entity ver1 is 
	port(
	clk		: in std_logic;  --100Mhz
	reset	: in std_logic;  -- 1 - reset
	uart_in : in std_logic;
	data_out : out std_logic;
	data_ready : out std_logic; -- 1 - ready
	)
end ver1;

--}} End of automatically maintained section

architecture ver1 of ver1 is
begin

	 -- enter your statements here --

end ver1;
