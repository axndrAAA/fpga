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
use IEEE.numeric_std.ALL;

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
<<<<<<< HEAD
	--constant msgSize		: integer := 6;
	constant msgSize 	: std_logic_vector(7 downto 0):=x"05";

	type stm_states is (
		waitData, -- ������� ������ � ����� �� ������ � message (��� ��������), � ���������� �� ������������ ������ ( �� ���� ������ ��� ������������ ������ 4 ����� ������)
		shiftDataToOutput, -- �������� ������ � message �� 8 ���, � ������� ���������� �� data_out
		transmitCS -- �������� ����������� �����
		--transmit -- �������� ������ �� �������� ����
	);
	
	signal stm		:	stm_states:= waitData; -- ���������� ��������� ��������� �������� 
	signal message	: std_logic_vector(39 downto 0):= (others => '0'); -- ����������� ��������
	signal tx_byte_index 	:	integer range 0 to 7:=0; -- ������� ����������� �����
	signal clk_1_byte_tx_counter	: std_logic_vector(19 downto 0):=(others => '0'); -- ������� �������� �� ����������� �� ����� ���������� �����
	signal cs_calc 	:	std_logic_vector(7 downto 0):=x"00"; -- ������ ��� �������� ����������� �����

=======
	--constant msgSize		: integer := 6-1;
	--constant msgSize		: std_logic_vector(3 downto 0):=x"6";
	--constant ssymb_adr_packSz: std_logic_vector(31 downto 0):= startSymbol & adr & commandSize;

	type stm_states is (
		waitData, -- ������� ������ � ����� �� ������ ������
		transmit_start_symbol, -- �������� ��������� ������
		transmit_module_adr, -- �������� ����� ������
		transmit_command_size, --�������� ������ ��������
		transmit_command, -- �������� ��������
		transmit_CS -- �������� ���� ����������� �����
		--formAnsw_addCS, -- ��������� �����. ������� � ����������� ����������� �����
		--transmit_data, -- �������� ������ �� �������� ����(��� ����� ����������� �����)
		--transmit_cs -- �������� �������������� ����������� �����
	);
	
	signal stm		:	stm_states:= waitData; -- ���������� ��������� ��������� �������� 
	--signal message	: std_logic_vector(47 downto 0):= (others => '0'); -- ����������� ��������
	--signal tx_byte_index 	:	integer range 0 to 7:=0; -- ������� ����������� �����
	signal tx_byte_index 	:	std_logic_vector(4 downto 0):=(others => '0'); -- ������� ����������� �����
	signal adr_buf	: std_logic_vector(7 downto 0):= (others => '0'); -- ����� ��� ������
	signal com_code_buf	: std_logic_vector(7 downto 0):= (others => '0'); -- ����� ��� ��������
	signal clk_1_byte_tx_counter	: std_logic_vector(19 downto 0):=(others => '0'); -- ������� �������� �� ����������� �� ����� ���������� �����
	signal cs_calc 	:	std_logic_vector(7 downto 0):=x"00"; -- ������ ��� �������� ����������� �����
	
>>>>>>> 04db91236edd4c62640423d6f7985e09c89f63fd
begin

main_pr:process(clk)
begin
	if(rising_edge(clk))then 
		if(reset = '1')then
			data_out <= (others => '0'); 
			tx_byte_index <= (others => '0');
			stm <= waitData;				
		else		 
		case stm is
			when waitData	=>	
				data_out_rdy <= '0';
<<<<<<< HEAD
				if(start = '1')then	  
					message <= startSymbol & adr & commandSize & com_code;
					clk_1_byte_tx_counter <= clk_1_byte_tx; -- ��� ����������, ��� ������������ �������� ������� �����
					stm <= shiftDataToOutput;
				end if;	
			when shiftDataToOutput => 
				data_out_rdy <= '0';
				if(tx_byte_index = msgSize)then
					tx_byte_index <= 0;
					stm <= transmitCS; -- ���� �������� ��� �������������� ����� �������� ��
				else
					if (clk_1_byte_tx_counter = clk_1_byte_tx)then
						message <= message(31 downto 0) & x"00";
						data_out <= message(39 downto 32);
						data_out_rdy <= '1'; 
						tx_byte_index <= tx_byte_index + 1;
						clk_1_byte_tx_counter <= x"00000";
					else
						clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
					end if;					
				end if;
			
			when transmitCS =>
				stm <= waitData;
			--when formAnsw_addCS => -- ������� � ���������� ����������� �����
--				message <= message(39 downto 0) & calcCS(message);
--				clk_1_byte_tx_counter <= clk_1_byte_tx; -- ��� ����������, ��� ������������ �������� ������� �����
--				stm <= transmit;
--			when transmit => -- �������� ������
--				data_out_rdy <= '0';
--				if(tx_byte_index = msgSize)then 											
--					tx_byte_index <= 0;
--					stm <= waitData; -- ���� �������� ��� ����� ������������ �� �������� 
--					else
--						if (clk_1_byte_tx_counter = clk_1_byte_tx)then
--							data_out <= message(8*(tx_byte_index + 1)-1 downto 8*tx_byte_index);
--							data_out_rdy <= '1'; 
--							tx_byte_index <= tx_byte_index + 1;
--							clk_1_byte_tx_counter <= x"00000";
--						else
--							clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
--						end if;					
--				end if;
=======
				if(start = '1')then	  												   
					adr_buf <= adr; -- ���������� ����� � �����
					com_code_buf <= com_code; -- � ��������
					clk_1_byte_tx_counter <= clk_1_byte_tx; -- ��� ���������� ��� ������������ �������� ������� �����
					stm <= transmit_start_symbol;
				end if;			
			when transmit_start_symbol => -- �������� ���������� �������
				if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= startSymbol;	-- ���������� ��������� ������
				   data_out_rdy <= '1'; 
				   clk_1_byte_tx_counter <= x"00000"; -- ����� �������� �������� ���������� uart_tx
				   stm <= transmit_module_adr;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;
			when transmit_module_adr =>	-- �������� ������ ������
				if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= adr_buf;	-- ���������� ����� ������ 
				   data_out_rdy <= '1'; 						   
				   cs_calc <= cs_calc + adr_buf; --������������ ����������� �����
				   clk_1_byte_tx_counter <= x"00000"; -- ������� �������� ���������� uart_tx
				   stm <= transmit_command_size;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;	  
			when transmit_command_size =>
				data_out_rdy <= '0';
				if(tx_byte_index = 2)then 											
					tx_byte_index <= (others =>'0');
					stm <= transmit_command; -- ���� �������� ��� �������� ��������
				else
					if (clk_1_byte_tx_counter = clk_1_byte_tx)then 
						data_out <= commandSize(8*(to_integer(unsigned(tx_byte_index)) + 1)-1 downto 8*to_integer(unsigned(tx_byte_index))); -- ���������� �� ����� ����
						cs_calc <= cs_calc + commandSize(8*(to_integer(unsigned(tx_byte_index)) + 1)-1 downto 8*to_integer(unsigned(tx_byte_index))); -- ������� ����������� ����
						data_out_rdy <= '1'; -- ���������� ���������� �����
						tx_byte_index <= tx_byte_index + 1; --������� ����
						clk_1_byte_tx_counter <= x"00000"; -- ������� �������� ���������� uart_tx
					else
							clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
					end if;					
				end if;
				--stm <= transmit_command; 		
			when  transmit_command => -- �������� ���� �������
			   if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= com_code_buf;	-- ���������� ��� ��������
				   data_out_rdy <= '1'; 						   
				   cs_calc <= cs_calc + com_code_buf; --������������ ����������� �����
				   clk_1_byte_tx_counter <= x"00000"; -- ����� �������� �������� ���������� uart_tx
				   stm <= transmit_CS;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;
			when transmit_CS =>	 -- �������� ����������� �����
				if (clk_1_byte_tx_counter = clk_1_byte_tx)then
				   data_out <= cs_calc;	-- ���������� ���� ����������� �����
				   data_out_rdy <= '1'; 						   
				   cs_calc <= (others => '0'); -- ���������� ����������� �����
				   clk_1_byte_tx_counter <= x"00000"; -- ����� �������� �������� ���������� uart_tx
				   stm <= waitData;
				else
					clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;
					data_out_rdy <= '0';
				end if;
--			when transmit_data => -- �������� ������
--				data_out_rdy <= '0';
--				if(tx_byte_index = msgSize)then 											
--					tx_byte_index <= (others =>'0');
--					stm <= transmit_cs; -- ���� �������� ��� �������� ����������� �����
--				else
--					if (clk_1_byte_tx_counter = clk_1_byte_tx)then
--						if(not tx_byte_index = 0)then
--							cs_calc <= cs_calc + message(8*(tx_byte_index + 1)-1 downto 8*tx_byte_index); -- ������� ����������� �����
--						end if;
--						data_out <= message(8*(tx_byte_index + 1)-1 downto 8*tx_byte_index); -- ���������� �� ����� ��������� ����
--						data_out_rdy <= '1'; -- ���������� ���������� �����
--						tx_byte_index <= tx_byte_index + 1; --������� ����
--						clk_1_byte_tx_counter <= x"00000"; -- ������� �������� ���������� uart_tx
--					else
--							clk_1_byte_tx_counter <= clk_1_byte_tx_counter + 1;						
--					end if;					
--				end if;
--			when transmit_cs =>
--				stm <= waitData; -- �������� ��� ����� ������������ �� ��������
>>>>>>> 04db91236edd4c62640423d6f7985e09c89f63fd
		end case;
		end if;
	end if;
end process main_pr;

end answBuild;
