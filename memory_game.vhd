LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity memory_game is
	port(
    clk_50 : in std_logic;                                 -- connected to 50 MHz clock PIN_AF14;
    btn_one, btn_two, btn_three, btn_four : in std_logic;  -- connected to KEY[0..3]
	 power_switch: in std_logic;                            --connected to the first switch to indicate game starts
	 diff_sw : in std_logic_vector(1 downto 0);             --last two switches that 
	 leds: out std_logic_vector(3 downto 0);                -- LEDR[3 downto 0]
	 input_val: out std_logic;                              -- LEDR[9]
	 hsync, vsync: out std_logic;                           --vga output drivers
    vga_r, vga_g, vga_b: out std_logic_vector(7 downto 0); --vga color channels
    vga_clk: out std_logic;                                --output clock for running the vga
    vga_sync: out std_logic;                               --sync the vga
    vga_blank: out std_logic;                              --clear the vga
    led_red: out std_logic                                 -- drive LEDR(9) with 1Hz clock from clock divider;
  );
end memory_game;

architecture my_structural of memory_game is

--lfsr component port mapping
--generates a 4 bit z value where
--only one index can be "1"
component LFSR 
  port (
    clk : in std_logic;
	 gen_next: in std_logic; 
    reset : in std_logic;
    z : out std_logic_vector (3 downto 0)
  );
end component;

--main component for handling and validating the input buttons
--returns status variables done and success, as well as the current combo streak and score update
component input_handler is
	port (
	  tick1, tick2, tick3, tick4: in std_logic;
	  reset: in std_logic;
	  clk: in std_logic;
	  expire: in std_logic;
	  expected_input: in std_logic_vector(3 downto 0);
	  done: out std_logic;
	  success: out std_logic;
	  out_combo: out integer;
     score_update: out integer
	);
end component;

--clk divider which generates a new clock signal based on the timeconst input
component clk_divider
  Port ( 
    CLK_IN : in STD_LOGIC;
    CLK_OUT : out STD_LOGIC;
	 TIMECONST: IN integer
  );
END COMPONENT;

--maps 3 bit rgb to the full 8 bit rgb per channel
component color_map
    port (
		sw : in std_logic_vector(3 downto 0);
		rgb: in std_logic_vector(2 downto 0);
		vga_r: out std_logic_vector(7 downto 0);
		vga_g: out std_logic_vector(7 downto 0);
		vga_b: out std_logic_vector(7 downto 0)
    );
end component;

signal slowClk : std_logic;                -- internal signal set by clock divider output
signal btn1, btn2, btn3, btn4 : std_logic; -- internal signal for the buttons
signal reset : std_logic;                  --internal reset from switch

--tracks the current input, 4 of the future inputs, and the previous input
signal curr_input, input_1, input_2, input_3, input_4, input_out : std_logic_Vector(3 downto 0) := "0000";

signal input_done: std_logic := '0';          --if something was enterred
signal input_success : std_logic := '0';      --if something was correct
signal score_inst, prev_score : integer := 0; --current and previous modifier which will be added to the score
signal time_out : integer := 100;             --the number if clock signals until an expected input expires
signal score : integer := 0;                  --the current achieved score of the game
signal difficulty_const : integer := 22;      --this affects the speed of the game clock, animations and time out
signal expire : std_logic := '0';             --when this is 1, the game moves to the next input
signal counter : integer := 0;                --used to track the number of clk events that occur between expiring

signal video_on, pixel_tick: std_logic;                       --internal signals for running the game
signal pixel_x, pixel_y: std_logic_vector (9 downto 0);       --current x and y pixel positions
signal rgb : std_logic_vector(2 downto 0);                    --3 digit representation of the current rgb value
signal dig3, dig2, dig1, dig0 : std_logic_vector(3 downto 0); --BCD digits for the score
signal text_rgb : std_logic_vector(2 downto 0); 				  --set the color based on the current text
signal text_on : std_logic;                                   --is the current pixel a text element
signal background_rgb: std_logic_vector(2 downto 0);          --the color for everything except text
signal out_combo : integer;                                   --the current combo multiplier
begin

btn1 <= not btn_one;  --when the button is pressed
btn2 <= not btn_two;  --when the button is pressed
btn3 <= not btn_three;--when the button is pressed
btn4 <= not btn_four; --when the button is pressed

reset <= not power_switch; --add ability to turn game off

color_map_inst : color_map port map ("0001", rgb, vga_r, vga_g, vga_b);  --instance of the color mapper with a fix color switch
clk_div_inst : clk_divider port map (clk_50, slowClk, difficulty_const); --creates the game clock
lsfr_inst : LFSR port map (slowClk, expire, reset, input_4);             --instance of lsfr to generate new sequences

--drive signals for handling the vga component
vga_sync <= '1';
vga_blank <= video_on;
vga_clk <= pixel_tick;

-- instantiate video synchonization unit
vga_sync_unit: entity work.vga_sync
  port map(clk=>clk_50, reset=>reset,
           video_on=>video_on, p_tick=>pixel_tick,
           hsync=>hsync, vsync=>vsync,
           pixel_x=>pixel_x, pixel_y=>pixel_y
			);

leds <= curr_input; --output the expected sequence to the leds

--input handler component instance
input_handler_inst : input_handler port map (btn1, btn2, btn3, btn4, reset, clk_50, expire, curr_input, input_done, input_success, out_combo, score_inst);

--instance of the m100_counter
--converts the score integer into 4 BCD digits
counter_unit : entity work.m100_counter
	port map(clk=> clk_50, reset=>reset,
				d_clr=>reset, score=>score,
				dig0=>dig0, dig1=>dig1, dig2=>dig2, dig3=>dig3
				);

--instance of the component for drawing the game
game_draw_unit: entity work.draw
 port map(
	CLK=>clk_50,
	reset=>reset,
   hPos=>pixel_x,
	videoOn=>video_on,
	vPos=>pixel_y,
	expected_input=>curr_input,
	input_1 => input_1,
	input_2 => input_2,
	input_3 => input_3,
	input_4 => input_4,
	input_out => input_out,
	clk_animate => slowClk,
	expire => expire,
   rgb => background_rgb
	);
	
--instance of the component for displaying the score	
score_draw_unit: entity work.score_text 
	port map(
		clk=>clk_50,
		reset=>reset,
		pixel_x=>pixel_x,
		pixel_y=>pixel_y,
		dig3=>dig3,
		dig2=>dig2,
		dig1=>dig1,
		dig0=>dig0,
		combo=>std_logic_vector(to_unsigned(out_combo, 4)),
		text_on=>text_on,
		text_rgb=>text_rgb		
	);
		
--process for updating the score when a change is made
process (score_inst, clk_50, reset)
begin
	if (clk_50'event and clk_50 = '1') then --if rising edge
		if (reset = '1') then
			score <= 0;
			prev_score <= 0;
		elsif (score_inst /= prev_score) then --if the update is new
			score <= score + score_inst; --update the score
			prev_score <= score_inst;
		end if;
	end if;
		
end process;
			
--process for setting the game difficulty based on the switches
--lower const = faster clock
process (diff_sw)
begin
	case diff_sw is
		when "00" =>
			difficulty_const <= 27;
		when "01" =>
			difficulty_const <= 24;
		when "10" =>
			difficulty_const <= 22;
		when "11" =>
			difficulty_const <= 20;
	end case;
end process;
	
--handles transferring to and from the current input queue	
--as well as triggering the expiration of the current input
process (slowClk)
begin
	if (slowClk'event and slowClk = '1') then --rising edge
		expire <= '0';
		if (counter < time_out) then --while its not timed out
			counter <= counter + 1;   --increment the counter
		else                         --if timed out  
			expire <= '1';            --trigger an expiration
			counter <= 0;             --reset the counter
			input_out <= curr_input;  --shift all the inputs forward one in the queue
			curr_input <= input_1;
			input_1 <= input_2;
			input_2 <= input_3;
			input_3 <= input_4;
		end if;
	end if;
end process;

--process for determining whether to display the score or the background
process(text_on,text_rgb, background_rgb)
  begin
       if (text_on='1') then    --if its currently a text pixel
          rgb <= text_rgb;      --output the text rgb
       else
         rgb <= background_rgb; --otherwise output the game rgb
       end if;
  end process; 


end my_structural;
