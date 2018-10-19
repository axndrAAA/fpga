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
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {answBuild} architecture {answBuild}}

library IEEE;
use IEEE.std_logic_1164.all;   
use IEEE.STD_LOGIC_unsigned.all;

entity answBuild is
	port(
		 clk 			: in std_logic; --  100 MHz
		 reset 			: in std_logic; -- 1-����� ���� �������(�����)
		 adr 		: in STD_LOGIC_VECTOR(7 downto 0); -- ����� ������
		 com_code 	: in STD_LOGIC_VECTOR(7 downto 0); -- ��� �������� (�������� �� ������� ������)
		 start		: in std_logic; -- ������ ������������ ������. ��� ���� �� ��������� ������ ��� ���� �������� ������
		 transmitter_rdy	: in std_logic; 	-- ���� �������� ���������� ��������� 
		 
		 data_out : out STD_LOGIC_VECTOR(7 downto 0); --8�� ������ �������� ����
		 data_out_rdy : out STD_LOGIC -- ���������� ������ �� ������
	     );
end answBuild;


architecture answBuild of answBuild is 
	constant startSymbol 	: std_logic_vector(7 downto 0):=x"3A"; -- ��������� ������ ������� 
	constant commandSize	: std_logic_vector(15 downto 0):=(others => '0'); -- ������ ������� (�� ������, ��� ������ �����, �� ����� 2� �������� 
	constant msgSize		: integer := 7;

	type stm_states is (
		waitStart, -- ������� ������, � ���������� �� ������������ ������
		formAnsw_addSS, -- ��������� �����. ���������� ��������� ������
		formAnsw_addAdr, -- ��������� �����.
		formAnsw_addSize, -- ��������� �����.
		formAnsw_addCommCode, -- ��������� �����.
		formAnsw_addCS, -- ��������� �����. ������� � ����������� ����������� �����
		transmit -- �������� ������ �� �������� ����
	);
	
	signal stm		:	stm_states:= waitStart; -- ���������� ��������� ��������� �������� 
	signal message	: std_logic_vector(47 downto 0):= (others => '0'); -- ����������� ��������
	signal tx_bit_index 	:	integer range 0 to 7:=0; -- ������� ����������� �����
	
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
			data_out_rdy <= '0';
			stm <= waitStart;				
		end if;				 

		case stm is
			when waitStart	=>	
				data_out <= (others => '0');
				data_out_rdy <= '0';
				if(start = '1')then
					stm <= formAnsw_addSS;
				end if;			
			when formAnsw_addSS => --���������� ��������� ������ (����� ����� ��������� ��� ��������, ��������� ������, ����� ������ � ������ ������ ����� ���������� �� ���������) 
				message <= message(39 downto 0) & startSymbol;
				stm <= formAnsw_addAdr;			
			when formAnsw_addAdr =>	-- ���������� ����� ������
				message <= message(39 downto 0) & adr;
				stm <= formAnsw_addSize;
			when formAnsw_addSize =>  -- ���������� ������ �������
				message <= message(31 downto 0) & commandSize;
				stm <= formAnsw_addCommCode;
			when formAnsw_addCommCode =>  -- ���������� ����� ������� 
				message <= message(39 downto 0) & com_code;
				stm <= formAnsw_addCS;
			when formAnsw_addCS => -- ������� � ���������� ����������� �����
				message <= message(39 downto 0) & calcCS(message);
			when transmit => -- �������� ������
				data_out_rdy <= '0';
				if(tx_bit_index = msgSize)then 
					stm <= waitStart; -- ���� �������� ��� ����� ������������ �� ��������
				elsif(transmitter_rdy = '1')then
					data_out <= message(47-(tx_bit_index*8) downto 47-((tx_bit_index+1)*8));
					data_out_rdy <= '1'; 
					tx_bit_index <= tx_bit_index + 1;
				end if;

			when others =>
				stm <= waitStart;
		end case;
		
		
	end if;

end process main_pr;

end answBuild;
