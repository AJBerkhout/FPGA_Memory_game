--Runs the primary animation for the game
--including animating the boxes across the screen

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

--current positions of the different values for the input queue
signal vpos1, vpos2, vpos3, vpos4, vposExpected, vposOut : integer;

--the start of the animation regions for each input
signal vpos1Init : integer := -65;
signal vpos2Init	: integer := 35;
signal vpos3Init : integer := 135;
signal vpos4Init : integer := 235;
signal vposExpectedInit : integer := 335;
signal vposOutInit : integer := 435;

--function for drawing the box based on the current input
function horiz_rgb (localH : std_logic_vector(9 downto 0); input: std_logic_vector(3 downto 0)) return std_logic_vector is
		variable rgb_local : std_logic_vector(2 downto 0);
	begin
		--if falls in the first box region
		if(localH >= std_logic_vector(to_unsigned(75, localH'length)) and localH <= std_logic_vector(to_unsigned(174, localH'length))) then
			if (input = "1000") then --and the first button is expected
				rgb_local := "010";
			else 
				rgb_local := "000";
			end if;
			
		--continue for the remaining 3 boxes
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
	
--draws the boxes for the expected input
--same as the previous function expect it also draws the white boxes
--which represent the hit zones for the input
function draw_expected (localH : std_logic_vector(9 downto 0); localV: std_logic_vector(9 downto 0); inputV: integer; input: std_logic_vector(3 downto 0)) return std_logic_vector is
		variable rgb_local : std_logic_vector(2 downto 0);
		variable vposBoxStart : integer := 385; --bounds for the white boxes visualizing the hitzones
		variable vposBoxEnd : integer := 435;
	begin
		
		--if the horizontal value is in the zone for the first box
		if(localH >= std_logic_vector(to_unsigned(75, localH'length)) and localH <= std_logic_vector(to_unsigned(174, localH'length))) then
			--if it is the first input 
			if (input = "1000" and std_logic_vector(to_unsigned(inputV, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(inputV+50, localV'length))) then
				rgb_local := "010";
			--otherwise, is it in the white box zone
			elsif(std_logic_vector(to_unsigned(vposBoxStart, localV'length)) <= localV and localV <= std_logic_vector(to_unsigned(vposBoxEnd, localV'length))) then
				rgb_local := "111";
			else
				rgb_local := "000";
			end if;
			
		--continue for the remaining 3 boxes
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
	
	--convert the 50 mhz clock to the 25 mhz clock
	clk_div:process(CLK)
	begin
		if(CLK'event and CLK = '1')then
		clk25 <= not clk25;
		end if;
	end process;
	
	--process for animating the boxes across the screen
	animate:process(clk_animate, expire)
	begin
		if (expire = '1') then
			vpos1 <= vpos1Init;               --reset to the base position on expire
			vpos2 <= vpos2Init;               
			vpos3 <= vpos3Init;               
			vpos4 <= vpos4Init;               
			vposExpected <= vposExpectedInit; 
			vposOut <= vposOutInit;           
		elsif (clk_animate'event and clk_animate = '1') then
			vpos1 <= vpos1 + 1;               --increment the top of the falling box by 1 at each rising edge
			vpos2 <= vpos2 + 1;
			vpos3 <= vpos3 + 1;
			vpos4 <= vpos4 + 1;
			vposExpected <= vposExpected + 1;
			vposOut <= vposOut + 1;
		end if;
	end process;

	--the main function for drawing the inputs 
	drawUL:process(clk25, reset, hPos, vPos, videoOn)
	begin
		if(reset = '1')then
					rgb <= "000";
		elsif(clk25'event and clk25 = '1')then --when rising edge
			if(videoOn = '1')then
				
				--divide the screen into various vertically stacked zones of length 5
				--if the vertical position falls between the the start and end of the given box input
				--draw the horizontal boxes for that inout
				if (vPos >= std_logic_vector(to_unsigned(vpos1, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos1+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_4);		
				--repeat this process for all of the falling boxes
				elsif (vPos >= std_logic_vector(to_unsigned(vpos2, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos2+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_3);			
				elsif (vPos >= std_logic_vector(to_unsigned(vpos3, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos3+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_2);			
				elsif (vPos >= std_logic_vector(to_unsigned(vpos4, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vpos4+50, vPos'length))) then
					rgb <= horiz_rgb(hPos, input_1);		
				--for the expected input, instead of adding 50, make the upper bound the start of the next box
				--this avoids overwriting the drawn white input boxes
				elsif (vPos >= std_logic_vector(to_unsigned(vPosExpectedInit, vPos'length))  and vPos <= std_logic_vector(to_unsigned(vposOut, vPos'length))) then
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
	

	
end arch;