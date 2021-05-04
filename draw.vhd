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
		expected_input: in std_logic_vector(3 downto 0);
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
				--if(((hPos >= "75" and hPos <= "174") OR (hPos >= "465" and hPos <= "564")) AND ((vPos >="400"  and vPos <= "750")))then
				if (vPos >="0101100010"  and vPos <= "0110010100") then
					if(hPos >= "0001001011" and hPos <= "0010101110") then
						if (expected_input = "1000") then
							rgb <= "110";
						else
							rgb <= "111";
						end if;
					elsif (hPos >= "0011001101" and hPos <= "0100110000") then
						if (expected_input = "0100") then
							rgb <= "110";
						else
							rgb <= "111";
						end if;
					elsif (hPos >= "0101001111" and hPos <= "0110110010")then
						if (expected_input = "0010") then
							rgb <= "110";
						else
							rgb <= "111";
						end if;
					elsif (hPos >= "0111010001" and hPos <= "1000110100") then
						if (expected_input = "0001") then
							rgb <= "110";
						else
							rgb <= "111";
						end if;
					else
						rgb <= "000";
					end if;			
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