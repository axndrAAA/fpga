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
use IEEE.STD_LOGIC_unsigned.all;
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
	constant clk_per_bit	: std_logic_vector(15 downto 0):=x"0361"; -- ����� ������ �� ������ ���
	type stm_states is (
		waitDataForBufering, -- ��������� ���������. �������� ������ �� �����
		txStartBit, -- �������� ���������� ����
		txData, -- �������� ������ 
		txStopBit -- �������� ��������� ����
	);
	
	signal st_main			:	stm_states:= waitDataForBufering; -- ���������� ��������� ��������� ��������
	signal tx_bit_index 	:	integer range 0 to 7:=0; -- ������� ����������� ����
	signal input_data_bufer	: 	std_logic_vector(7 downto 0):=(others => '0'); -- ������� �����
	signal clk_bit_counter	: 	std_logic_vector(15 downto 0); -- ������� ������� ��������� ������� ��� �������� ����  
	
	
begin
  	main_pr : process(clk) 
	  begin
	  	if (rising_edge(clk)) then
			if(reset = '1')  then
				st_main	<= waitDataForBufering;
				clk_bit_counter <=(others=>'0');
			else
			case st_main is				
				when waitDataForBufering => -- ����� �������� ������ �� �����
					uart_out <= '1'; --	����������� ����� � ���������� 
					tx_bit_index <= 0; -- �������� ������� ���������� ���
					if (data_in_rdy = '1')then -- ���� �� ������� ���� ���� �������� ������	
						input_data_bufer <= data_in; -- ����������� ��. ������
						st_main <= txStartBit; -- �������� � �������� �������
						clk_bit_counter <=(others=>'0'); -- �������� �������
					end if;	
				when txStartBit =>
					uart_out <= '0'; -- ������������� ���.0 �� �����
					if(clk_bit_counter < clk_per_bit)then -- ����������� ������������ ����
						clk_bit_counter <= clk_bit_counter + '1';
					else
						clk_bit_counter <=(others=>'0');-- ���� ���������, ���������� �������, �
						st_main <= txData; -- ��������� � �������� ����� ������
					end if;
				when txData => 
					uart_out <= input_data_bufer(tx_bit_index); -- ���������� ������������ ��� �� �������� �����
					if(clk_bit_counter < clk_per_bit)then -- ����������� ������������ ���� 
						clk_bit_counter <= clk_bit_counter + '1';
					else 					
						clk_bit_counter <=(others=>'0');-- ���� ���������, ���������� �������
						if (tx_bit_index < 7)then -- � ��������� �� ��������� �� �������� �������
							tx_bit_index <=	 tx_bit_index + 1; -- ���� �� ���������, ��������� � �������� ���������� ����
						else
							st_main <= txStopBit; -- ���� ���������, ��������� � �������� ��������� ����
						end if;	
					end if;
				
				when txStopBit =>
					uart_out <= '1';
					if(clk_bit_counter < clk_per_bit)then -- ����������� ������������ ����
						clk_bit_counter <= clk_bit_counter + '1';
					else
						clk_bit_counter <=(others=>'0');-- ���� ���������, ���������� �������
						st_main <= waitDataForBufering; -- � ��������� � �������� ��������� �������
					end if;							
				end case;
				end if;
		end if;		  
	end process main_pr;   
		

end uart_tx;
