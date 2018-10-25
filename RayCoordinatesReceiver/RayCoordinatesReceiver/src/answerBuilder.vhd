-------------------------------------------------------------------------------
--
-- Title       : answBuild
-- Design      : RayCoordinatesReceiver
-- Author      : Alexander
-- Company     : MAI
--
-------------------------------------------------------------------------------
--
-- File        : e:\git\fpga\RayCoordinatesReceiver\RayCoordinatesReceiver\src\answerBuilder.vhd
-- Generated   : Fri Oct 19 14:10:56 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 	������ ���������� ����� �� ����� uart
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;   
use IEEE.STD_LOGIC_unsigned.all;

entity answBuild is
	port(
		 clk 			: in std_logic; --  100 MHz
		 reset 			: in std_logic; -- 1-����� ���� �������(�����)
		 adr 		: in STD_LOGIC_VECTOR(7 downto 0); -- ����� ������ (����������, ����� �� ��� ��������� ������)
		 com_code 	: in STD_LOGIC_VECTOR(7 downto 0); -- ��� �������� (�������� �� ������� ������)
		 start		: in std_logic; -- ������ ������������ ������. ��� ���� �� ��������� ������ ��� ���� �������� ������
		 
		 data_out : out STD_LOGIC_VECTOR(7 downto 0); --8�� ������ �������� ����
		 data_out_rdy : out STD_LOGIC -- ���������� ������ �� ������
	     );
end answBuild;


architecture answBuild of answBuild is 
	constant startSymbol 	: std_logic_vector(7 downto 0):=x"3A"; -- ��������� ������ ������� 
	constant commandSize	: std_logic_vector(15 downto 0):=x"0002"; -- ������ ������� (�� ������, ��� ������ �����, �� ����� 2� �������� 
	constant clk_1_byte_tx	: std_logic_vector(19 downto 0):=x"021D4"; -- ����� ������ �� ������� ���������� �������� ����� ��������� �� uart �� �������� 115200
	constant msgSize		: integer := 6;
	--constant ssymb_adr_packSz: std_logic_vector(31 downto 0):= startSymbol & adr & commandSize;

	type stm_states is (
		waitData, -- ������� ������ � ����� �� ������ � message (��� ��������), � ���������� �� ������������ ������ ( �� ���� ������ ��� ������������ ������ 4 ����� ������)
		formAnsw_addCS, -- ��������� �����. ������� � ����������� ����������� �����
		transmit -- �������� ������ �� �������� ����
	);
	
	signal stm		:	stm_states:= waitData; -- ���������� ��������� ��������� �������� 
	signal message	: std_logic_vector(47 downto 0):= (others => '0'); -- ����������� ��������
	signal tx_byte_index 	:	integer range 0 to 7:=0; -- ������� ����������� �����
	signal clk_1_byte_tx_counter	: std_logic_vector(19 downto 0):=(others => '0'); -- ������� �������� �� ����������� �� ����� ���������� �����
	
function calcCS ( message : in std_logic_vector(47 downto 0) ) return std_logic_vector is	
begin 
	-- TODO:
	-- ����� ����������� ������� ����������� �����
	return x"AE";
end function;

begin

main_pr:process(clk)
begin
	if(rising_edge(clk))then 
		if(reset = '1')then
			data_out <= (others => '0'); 
			tx_byte_index <= 0;
			stm <= waitData;				
		else		 
		case stm is
			when waitData	=>	
				data_out_rdy <= '0';
				if(start = '1')then	  
					message <=  message(7 downto 0) & startSymbol & adr & commandSize & com_code;
					stm <= formAnsw_addCS;
				end if;			
			when formAnsw_addCS => -- ������� � ���������� ����������� �����
				message <= message(39 downto 0) & calcCS(message);
				clk_1_byte_tx_counter <= clk_1_byte_tx; -- ��� ����������, ��� ������������ �������� ������� �����
				stm <= transmit;
			when transmit => -- �������� ������
				data_out_rdy <= '0';
				if(tx_byte_index = msgSize)then 											
					tx_byte_index <= 0;
					stm <= waitData; -- ���� �������� ��� ����� ������������ �� �������� 
					else
						if (clk_1_byte_tx_counter = clk_1_byte_tx)then
							data_out <= message(8*(tx_byte_index + 1)-1 downto 8*tx_byte_index);
							data_out_rdy <= '1'; 
							tx_byte_index <= tx_byte_index + 1;
							clk_1_byte_tx_counter <= x"00000";
						else
							clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
						end if;					
				end if;
		end case;
		end if;
	end if;
end process main_pr;

end answBuild;
