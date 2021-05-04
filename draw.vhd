library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity draw is
   port(
      CLK, reset: in std_logic;
      hPos:in std_logic_vector (9 downto 0);
		vPos:in std_logic_vector (9 downto 0);
      --R,G,B: out std_logic_vector(3 downto 0);
		rgb: out std_logic_vector(2 downto 0);
		expected_input, input_1, input_2, input_3: in std_logic_vector(3 downto 0);
		--timer_60Hz: in std_logic;
		videoOn: in std_logic
   );
end draw;

architecture arch of draw is

signal clk25 : std_logic := '0';
--signal rectangle_on: std_logic; --new
--signal rectangle_rgb: std_logic_vector(2 downto 0);
signal pixel_x_note: unsigned(9 downto 0);
signal pixel_y_note: unsigned(9 downto 0);
signal pixel_x_note_next: unsigned(9 downto 0);
signal pixel_y_note_next: unsigned(9 downto 0);
----------------------------------------------------------------
--new added 5/3/2021

----------------------------------------------------------------
function horiz_rgb (localH : std_logic_vector(9 downto 0); input: std_logic_vector(3 downto 0); color_blanks: std_logic) return std_logic_vector is
		variable rgb_local : std_logic_vector(2 downto 0);
	begin
		if(localH >= std_logic_vector(to_unsigned(75, localH'length)) and localH <= std_logic_vector(to_unsigned(174, localH'length))) then
			if (input = "1000") then
				rgb_local := "010";
			elsif (color_blanks = '1') then
				rgb_local := "111";
			else 
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(205, localH'length)) and localH <= std_logic_vector(to_unsigned(304, localH'length))) then
			if (input = "0100") then
				rgb_local := "010";
			elsif (color_blanks = '1') then
				rgb_local := "111";
			else 
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(335, localH'length)) and localH <= std_logic_vector(to_unsigned(434, localH'length))) then
			if (input = "0010") then
				rgb_local := "010";
			elsif (color_blanks = '1') then
				rgb_local := "111";
			else 
				rgb_local := "000";
			end if;
		elsif (localH >= std_logic_vector(to_unsigned(465, localH'length)) and localH <= std_logic_vector(to_unsigned(564, localH'length))) then
			if (input = "0001") then
				rgb_local := "010";
			elsif (color_blanks = '1') then
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
--------------------------------------------------------------------------------------------------------------------------
--639 horizontal
----479 vertical
	
	--upper left box
	drawUL:process(clk25, reset, hPos, vPos, videoOn)
	begin
		if(reset = '1')then
					rgb <= "000";
		elsif(clk25'event and clk25 = '1')then
			if(videoOn = '1')then
				if (vPos >= std_logic_vector(to_unsigned(360, vPos'length))  and vPos <= std_logic_vector(to_unsigned(410, vPos'length))) then
					rgb <= horiz_rgb(hPos, expected_input, '1');			
				elsif (vPos >= std_logic_vector(to_unsigned(260, vPos'length))  and vPos <= std_logic_vector(to_unsigned(310, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_1, '0');			
				elsif (vPos >= std_logic_vector(to_unsigned(160, vPos'length))  and vPos <= std_logic_vector(to_unsigned(210, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_2, '0');			
				elsif (vPos >= std_logic_vector(to_unsigned(60, vPos'length))  and vPos <= std_logic_vector(to_unsigned(110, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_3, '0');			
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