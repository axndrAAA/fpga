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
-- Description : 	������ � ����������� ��� �������� ������� 
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity packageParser is	
	 port(
		 clk 			: in std_logic; --  100 MHz
		 reset 			: in std_logic; -- 1-����� ���� �������(�����)
		 module_adress 	: in std_logic_vector(7 downto 0); -- ����� ����������
		 data_input		: in std_logic_vector(7 downto 0);  -- ������� ������ �� uart ���������
		 data_input_rdy : in std_logic; -- ���������� ������ �� ����� �� uart ���������

		 command_output_rdy : out std_logic; -- 1-����� �� �� ����� LsinA, command_output � LsinB ����������� �������� ������ � ����� ����������� �������� �������
		 LsinA : out std_logic_vector(31 downto 0); -- 32� ������ ���� ��� ��������� �������� ������ ���� � ���������� ���� 
		 LsinB : out std_logic_vector(31 downto 0);	-- 32� ������ ���� ��� ��������� �������� ������ ���� B ���������� ���� 
		 command_output		: out std_logic_vector(7 downto 0)	-- ���� ������������ ��� �������� ������� ������
	     );
end packageParser;

architecture packageParser of packageParser is
constant StartSymbol 		: std_logic_vector(7 downto 0):=x"3A"; -- ��������� ������ �������
constant multicastAddress 	: std_logic_vector(7 downto 0):=x"0E"; -- ����� ��� �������������� ������� 
constant commandCode		: std_logic_vector(7 downto 0):=x"22"; -- ��� �������� ��� ������� ������

	type stm_states is (
		waitStartSymbol, -- ���������� ���������� ������� �������
		readModuleAdr, -- ���������� ������ ������ �� �������
		readPackageBodySize, -- ���� ��� ������ ��������� ������ ������� ����������
		multucastAdrRead, -- ���� ��� ������ �������������� ������ (15)
		readCommand, -- ���������  ��������
		readPackageBody, -- ��������� ���� ������
		readReserveByte, --��������� ��������� ����
		read_check_CS_byte -- ��������� ���� ����������� ����� ��������� �. ���� ��������� �� ����� ���������� ������ �� �����
	);
	signal stm_parser		:	stm_states:= waitStartSymbol; -- ���������� ��������� ��������� ��������
	signal inp_command_code_buf : std_logic_vector(7 downto 0):=x"00"; -- ����� ��� ������������ ���� �������
	signal inp_pack_body_buf : std_logic_vector(63 downto 0); -- ����� ��� ������������ ���� ������
	
	signal recv_byte_count 	:	std_logic_vector(7 downto 0):=x"00"; -- ������� ��������� ���(������������ ��� ������ ����������� �����)
	signal packageBodySize	: 	std_logic_vector(15 downto 0):=(others => '0'); -- ������ ������� (����������� �� ������� �� �����)
	signal CS_recv_byte 	:	std_logic_vector(7 downto 0):=x"00";  
	signal cs_calc 	:	std_logic_vector(7 downto 0):=x"00";
	
begin
	main_pr : process(clk)
	begin					
		if(rising_edge(clk))then
			if(reset = '1')then -- ����� ����� �������
				stm_parser <= waitStartSymbol;
				command_output_rdy <= '0';
				LsinA <= (others => '0');
				LsinB <= (others => '0');
				command_output <= (others => '0'); 
				recv_byte_count <= x"00";
			else			
			case stm_parser is			
				when waitStartSymbol =>
					command_output_rdy <= '0'; -- ����� �� �����
					cs_calc <= (others =>'0'); -- ����� �������� ����������� ����� 
					--��� �� �����, �� ��� ������� �����
					LsinA <= (others => '0');
					LsinB <= (others => '0');
					command_output <= (others => '0');	
					--
					if(data_input_rdy = '1')then
						if(data_input = StartSymbol)then -- ������� ��������� ������ �������, �� ���������� ��� � input_message
							stm_parser <= readModuleAdr; -- ��������� � ���������� ������ ������
						else 							 -- ������� ����� �� �����. 
							stm_parser <= waitStartSymbol; -- ������������ � �������� ���������� �������
						end if;						
					end if;
				
				when readModuleAdr =>
					if(data_input_rdy = '1')then
						if(data_input = module_adress)then -- ������ ����� ������� ������	
							cs_calc <= cs_calc + data_input; -- ���������� ��������� ���� � ����������� �����
							stm_parser <= readPackageBodySize; -- ��������� � ���������� �������
						elsif (data_input = multicastAddress)then -- ������� ����� ����� 
							cs_calc <= cs_calc + data_input; -- ���������� ��������� ���� � ����������� �����
							stm_parser <= multucastAdrRead; -- ��������� � ���������� ����� ������� 
						else 
							stm_parser <= waitStartSymbol; -- ������ ����� -> ������������ � �������� ���������� �������
						end if;
						recv_byte_count <= (others=> '0'); -- ���������� ������� �������� ����
					end if;					
				
				when readPackageBodySize =>
				if(data_input_rdy = '1')then -- ��������� ������ �������
						packageBodySize <= packageBodySize(7 downto 0) & data_input; -- ��������� ������ � ��������� ����������
						cs_calc <= cs_calc + data_input; -- ���������� ��������� ���� � ����������� �����
						recv_byte_count <= recv_byte_count + 1;	
						
						if(recv_byte_count = 1)then	-- ������� ��� ����� ������� �������
						  	recv_byte_count <= (others=> '0');		-- ���������� ������� �������� ����
						  	stm_parser <= readCommand; -- � ��������� � ���������� �������
						end if;
					end if;				
				when multucastAdrRead =>
					if(data_input_rdy = '1')then
						-- �������� ����������� ��� ���������� ������ ������
						stm_parser <= waitStartSymbol;
					end if;
				when readCommand =>
					if(data_input_rdy = '1')then -- ��������� ��������
					 	if(data_input = commandCode)then -- ���� ����������� �������� �������� ��� ���, �� ��������� ���� ������
							 inp_command_code_buf <= data_input; --��������� �������� � �����
							 cs_calc <= cs_calc + data_input; -- ���������� ��������� ���� � ����������� �����
							 stm_parser <= readPackageBody;
						else
							stm_parser <= waitStartSymbol; -- �������� �� ����, ������������ � �������� ������
						end if;	
					end if;				
				when readPackageBody => 
				if(data_input_rdy = '1')then -- ��������� ���� ������ (8 ����)
					inp_pack_body_buf <= inp_pack_body_buf(55 downto 0) & data_input;
					cs_calc <= cs_calc + data_input; -- ���������� ��������� ���� � ����������� �����
						recv_byte_count <= recv_byte_count + 1;	
						
						if(recv_byte_count = (packageBodySize-1))then -- ��� ����� ���� ������ ������� ���� ������
							recv_byte_count <= (others=> '0');
							stm_parser <= readReserveByte;
						end if;
					end if;				
				when readReserveByte =>
					if(data_input_rdy = '1')then -- ������ ��������� ����
						cs_calc <= cs_calc + data_input; -- ���������� ��������� ���� � ����������� �����
						stm_parser <= read_check_CS_byte;
					end if;	
				when read_check_CS_byte =>
					if(data_input_rdy = '1')then -- ������ � ������� ���� ����������� �����
						if(data_input = cs_calc)then -- ���� ����������� ����� �����, ���������� ������� �� �����	 
							LsinA <= inp_pack_body_buf(63 downto 32);
							LsinB <= inp_pack_body_buf(31 downto 0);
							command_output <= commandCode;
							command_output_rdy <= '1'; -- �������� ������� �� ������������ ������
							stm_parser <= waitStartSymbol;-- � ��������� �� ��������
						else
							stm_parser <= waitStartSymbol; -- ����������� ����� �� �����, ������� ����� �����
						end if;
					end if;	 
				end case; 
				end if;
		end if;
	end process main_pr;


end packageParser;
