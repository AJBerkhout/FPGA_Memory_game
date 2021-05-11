library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity draw is
   port(
      CLK, reset: in std_logic;
      hPos:in std_logic_vector (9 downto 0);
		vPos:in std_logic_vector (9 downto 0);
		rgb: out std_logic_vector(2 downto 0);
		expected_input, input_1, input_2, input_3, input_4, input_out: in std_logic_vector(3 downto 0);
		clk_animate : in std_logic;
		expire : in std_logic;
		videoOn: in std_logic
   );
end draw;

architecture arch of draw is

signal clk25 : std_logic := '0';

signal vpos1, vpos2, vpos3, vpos4, vposExpected, vposOut : integer;
signal vpos1Init : integer := -65;
signal vpos2Init	: integer := 35;
signal vpos3Init : integer := 135;
signal vpos4Init : integer := 235;
signal vposExpectedInit : integer := 335;
signal vposOutInit : integer := 435;


function horiz_rgb (localH : std_logic_vector(9 downto 0); input: std_logic_vector(3 downto 0)) return std_logic_vector is
		variable rgb_local : std_logic_vector(2 downto 0);
	begin
		if(localH >= std_logic_vector(to_unsigned(75, localH'length)) and localH <= std_logic_vector(to_unsigned(174, localH'length))) then
			if (input = "1000") then
				rgb_local := "010";
			else 
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(205, localH'length)) and localH <= std_logic_vector(to_unsigned(304, localH'length))) then
			if (input = "0100") then
				rgb_local := "010";
			else
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(335, localH'length)) and localH <= std_logic_vector(to_unsigned(434, localH'length))) then
			if (input = "0010") then
				rgb_local := "010";
			else 
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(465, localH'length)) and localH <= std_logic_vector(to_unsigned(564, localH'length))) then
			if (input = "0001") then
				rgb_local := "010";
			else 
				rgb_local := "000";
			end if;
		else 
			rgb_local := "000";
		end if;
		return rgb_local;
	end function;
	
function draw_expected (localH : std_logic_vector(9 downto 0); localV: std_logic_vector(9 downto 0); inputV: integer; input: std_logic_vector(3 downto 0)) return std_logic_vector is
		variable rgb_local : std_logic_vector(2 downto 0);
		variable vposBoxStart : integer := 385;
		variable vposBoxEnd : integer := 435;
	begin
		
		if(localH >= std_logic_vector(to_unsigned(75, localH'length)) and localH <= std_logic_vector(to_unsigned(174, localH'length))) then
			if (input = "1000" and std_logic_vector(to_unsigned(inputV, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(inputV+50, localV'length))) then
				rgb_local := "010";
			elsif(std_logic_vector(to_unsigned(vposBoxStart, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(vposBoxEnd, localV'length))) then
				rgb_local := "111";
			else
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(205, localH'length)) and localH <= std_logic_vector(to_unsigned(304, localH'length))) then
			if (input = "0100" and std_logic_vector(to_unsigned(inputV, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(inputV+50, localV'length))) then
				rgb_local := "010";
			elsif(std_logic_vector(to_unsigned(vposBoxStart, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(vposBoxEnd, localV'length))) then
				rgb_local := "111";
			else
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(335, localH'length)) and localH <= std_logic_vector(to_unsigned(434, localH'length))) then
			if (input = "0010" and std_logic_vector(to_unsigned(inputV, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(inputV+50, localV'length))) then
				rgb_local := "010";
			elsif(std_logic_vector(to_unsigned(vposBoxStart, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(vposBoxEnd, localV'length))) then
				rgb_local := "111";
			else
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(465, localH'length)) and localH <= std_logic_vector(to_unsigned(564, localH'length))) then
			if (input = "0001" and std_logic_vector(to_unsigned(inputV, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(inputV+50, localV'length))) then
				rgb_local := "010";
			elsif(std_logic_vector(to_unsigned(vposBoxStart, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(vposBoxEnd, localV'length))) then
				rgb_local := "111";
			else
				rgb_local := "000";
			end if;
		else 
			rgb_local := "000";
		end if;
		return rgb_local;
	end function;

begin

	clk_div:process(CLK)
	begin
		if(CLK'event and CLK = '1')then
		clk25 <= not clk25;
		end if;
	end process;
	
	animate:process(clk_animate, expire)
	begin
		if (expire = '1') then
			vpos1 <= vpos1Init;
			vpos2 <= vpos2Init;
			vpos3 <= vpos3Init;
			vpos4 <= vpos4Init;
			vposExpected <= vposExpectedInit;
			vposOut <= vposOutInit;
		elsif (clk_animate'event and clk_animate = '1') then
			vpos1 <= vpos1 + 1;
			vpos2 <= vpos2 + 1;
			vpos3 <= vpos3 + 1;
			vpos4 <= vpos4 + 1;
			vposExpected <= vposExpected + 1;
			vposOut <= vposOut + 1;
		end if;
	end process;

	drawUL:process(clk25, reset, hPos, vPos, videoOn)
	begin
		if(reset = '1')then
					rgb <= "000";
		elsif(clk25'event and clk25 = '1')then
			if(videoOn = '1')then
				if (vPos >= std_logic_vector(to_unsigned(vpos1, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos1+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_4);			
				elsif (vPos >= std_logic_vector(to_unsigned(vpos2, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos2+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_3);			
				elsif (vPos >= std_logic_vector(to_unsigned(vpos3, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos3+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_2);			
				elsif (vPos >= std_logic_vector(to_unsigned(vpos4, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos4+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_1);		
				elsif (vPos >= std_logic_vector(to_unsigned(vPosExpectedInit, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vPosOutInit, vPos'length))) then
					rgb <= draw_expected(hPos, vPos, vposExpected, expected_input);		
				elsif (vPos >= std_logic_vector(to_unsigned(vposOut, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vposOut+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_out);			
				else
					rgb <= "000";
				end if;--ends bottom blocks
			else
					rgb <= "000";
			end if;
		end if;
	end process;
	

-- [(hPos >= "0000001010" and hPos <= "0000111100") OR (hPos >= "1001011000" and hPos <= "1100010101")] AND [(vPos >="0000001010"  and vPos <= "0000111100") OR (vPos >="0110010000"  and vPos <= "1011101110")]
	--upper right box 
---------------------------------------------------------------------------------------------------------------------------------
	--639 horizontal
----479 vertical
	

	
end arch;