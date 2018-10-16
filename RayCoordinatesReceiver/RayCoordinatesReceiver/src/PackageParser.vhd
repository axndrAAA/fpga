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
		 reset 			: in std_logic; -- 1-����� ���� �������(�����)
		 module_adress 	: in std_logic_vector(7 downto 0); -- ����� ����������
		 data_input		: in std_logic_vector(7 downto 0);  -- ������� ������ �� uart ���������
		 data_input_rdy : in std_logic; -- ���������� ������ �� ����� �� uart ���������
		 
		 coord_data_rdy : out std_logic; -- 1-����� �� ����� ����� LsinA � LsinB ����������� �������� ������
		 command_rdy : out std_logic; -- 1-����� �� ���� command_output ������������ � ����������� �������� �������
		 LsinA : out std_logic_vector(31 downto 0); -- 32� ������ ���� ��� ��������� �������� ������ ���� � ���������� ���� 
		 LsinB : out std_logic_vector(31 downto 0);	-- 32� ������ ���� ��� ��������� �������� ������ ���� B ���������� ���� 
		 command_output : out std_logic_vector(7 downto 0) -- 8� ������ ���� ��� �������� ������������ ����� � �������� uart.
	     );
end packageParser;

architecture packageParser of packageParser is
constant StartSymbol 		: std_logic_vector(7 downto 0):=x"3A"; -- ��������� ������ �������
constant multicastAddress 	: std_logic_vector(7 downto 0):=x"15"; -- ����� ��� �������������� �������

	type stm_states is (
	   	waitData, -- �������� ������
		readStartSymbol, -- ���������� ���������� ������� �������
		readModuleAdr, -- ���������� ������ ������ �� �������
		specAdrRead, -- ���� ��� ������ ��������� ������ ������� ����������
		multucastAdrRead -- ���� ��� ������ �������������� ������ (15)
	);
	signal stm_parser	:	stm_states:= waitData; -- ���������� ��������� ��������� ��������






begin
	main_pr : process(clk)
	begin					
		if(rising_edge(clk))then
			if(reset = '1')then -- ����� ����� �������
				stm_parser <= waitData;
				coord_data_rdy <= '0';
				command_rdy <= '0';
				LsinA <= (others => '0');
				LsinB <= (others => '0');
				command_output <= (others => '0');
			end if;
			
			case stm_parser is
				when waitdata => -- ������� ������� ���������� �������
					if(data_input_rdy = '1')then
						stm_parser <= readStartSymbol;
					end if;				
				when readStartSymbol =>
					if(data_input_rdy = '1')then
						if(data_input = StartSymbol)then -- ������� ��������� ������ �������
							stm_parser <= readModuleAdr; -- ��������� � ���������� ������ ������
						else 							 -- ������� ����� �� �����. 
							stm_parser <= waitData; -- ������������ � �������� ���������� �������
						end if;						
					end if;
				
				when readModuleAdr =>
					if(data_input_rdy = '1')then
						if(data_input = module_adress)then -- ������ ����� ������� ������
							stm_parser <= specAdrRead; -- ��������� � ���������� �������
						elsif (data_input = multicastAddress) -- ������� ����� ����� 
							stm_parser <= multucastAdrRead; -- ��������� � ���������� ����� ������� 
						else 
							stm_parser <= waitData; -- ������ ����� -> ������������ � �������� ���������� �������
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
