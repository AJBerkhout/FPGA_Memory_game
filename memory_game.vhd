LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity memory_game is
	port(
    clk_50 : in std_logic; -- connected to 50 MHz clock PIN_AF14;
    btn_one, btn_two, btn_three, btn_four : in std_logic; -- connected to KEY[0..4]
	 power_switch: in std_logic; --connected to the first switch to indicate game starts
	 diff_sw : in std_logic_vector(1 downto 0);
	 leds: out std_logic_vector(3 downto 0); -- LEDR[3 downto 0]
	 input_val: out std_logic; -- LEDR[9]
	 hsync, vsync: out std_logic;
    vga_r, vga_g, vga_b: out std_logic_vector(7 downto 0);
    vga_clk: out std_logic;
    vga_sync: out std_logic;
    vga_blank: out std_logic;
    led_red: out std_logic -- drive LEDR(9) with 1Hz clock from clock divider;
  );
end memory_game;

architecture my_structural of memory_game is

component LFSR 
  port (
    clk : in std_logic;
	 gen_next: in std_logic; 
    reset : in std_logic;
    z : out std_logic_vector (3 downto 0)
  );
end component;

--port mapping for edge_detect internal component
component edge_detect is 
  port (
    clk, reset: in std_logic;
    level: in std_logic;
    tick: out std_logic
  );
end component;

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

COMPONENT my_altpll 
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic         -- outclk0.clk
	);
end component;	

component clk_divider
  Port ( 
    CLK_IN : in STD_LOGIC;
    CLK_OUT : out STD_LOGIC;
	 TIMECONST: IN integer
  );
END COMPONENT;

  
component vga_driver
 port(
	CLK, reset: in std_logic;
   hPos:in std_logic_vector (9 downto 0);
	vPos:in std_logic_vector (9 downto 0);
	videoOn: in std_logic;
   RGB: out std_logic_vector(2 downto 0)
 );
end component;

component color_map
    port (
		sw : in std_logic_vector(3 downto 0);
		rgb: in std_logic_vector(2 downto 0);
		vga_r: out std_logic_vector(7 downto 0);
		vga_g: out std_logic_vector(7 downto 0);
		vga_b: out std_logic_vector(7 downto 0)
    );
end component;

signal clk, slowClk : std_logic; -- internal signal set by clock divider output
signal btn1, btn2, btn3, btn4 : std_logic; -- internal signal for the buttons
signal tick1, tick2, tick3, tick4 : std_logic; -- internal signal for the buttons
signal reset : std_logic;
signal curr_input, input_1, input_2, input_3, input_4, input_out : std_logic_Vector(3 downto 0) := "0000";
signal input_done: std_logic := '0';
signal input_success : std_logic := '0';
signal score_inst, local_counter, prev_score : integer := 0;
signal time_out : integer := 100;
signal score : integer := 0;
signal difficulty_const : integer := 22;
signal expire : std_logic := '0';
signal counter : integer := 0;

signal video_on, pixel_tick: std_logic;
signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
signal rgb : std_logic_vector(2 downto 0);
signal dig3, dig2, dig1, dig0 : std_logic_vector(3 downto 0);
signal incr_score : std_logic := '0';
signal text_rgb : std_logic_vector(2 downto 0);
signal text_on : std_logic;
signal background_rgb: std_logic_vector(2 downto 0);
signal out_combo : integer;
begin


color_map_inst : color_map port map ("0001", rgb, vga_r, vga_g, vga_b);
btn1 <= not btn_one; --when the button is pressed
btn2 <= not btn_two; --when the button is pressed
btn3 <= not btn_three; --when the button is pressed
btn4 <= not btn_four; --when the button is pressed

reset <= not power_switch; --add ability to turn game off
clk_div_inst : clk_divider port map (clk_50, slowClk, difficulty_const);
alt_pll_inst : my_altpll port map (clk_50, reset, clk); --instance of clk_divider component
lsfr_inst : LFSR port map (slowClk, expire, reset, input_4); --instance of lsfr to generate new sequences

-- instantiate color mapper
--color_map_unit: entity work.color_map port map(sw, rgb_reg, vga_r, vga_g, vga_b);

----------------------------------------------------------------------------------------
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

leds <= std_logic_vector(to_unsigned(out_combo,4)); --output the expected sequence to the leds
--input handler component instance
input_handler_inst : input_handler port map (btn1, btn2, btn3, btn4, reset, clk_50, expire, curr_input, input_done, input_success, out_combo, score_inst);

 
counter_unit : entity work.m100_counter
	port map(clk=> clk_50, reset=>reset,
				d_inc=>incr_score, d_clr=>reset, score=>score,
				dig0=>dig0, dig1=>dig1, dig2=>dig2, dig3=>dig3
				);

process (score_inst, clk_50, reset)
begin
	if (clk_50'event and clk_50 = '1') then
		if (reset = '1') then
			score <= 0;
			prev_score <= 0;
		elsif (score_inst /= prev_score) then
			score <= score + score_inst;
			prev_score <= score_inst;
		end if;
	end if;
		
end process;
			

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
			
process (slowClk)
begin
	if (slowClk'event and slowClk = '1') then
		expire <= '0';
		if (counter < time_out) then
			counter <= counter + 1;
		else
			expire <= '1';
			counter <= 0;
			input_out <= curr_input;
			curr_input <= input_1;
			input_1 <= input_2;
			input_2 <= input_3;
			input_3 <= input_4;
		end if;
	end if;
end process;

---------------------------------------------------------------------------------

	U1: entity work.draw
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
		
	U2 : entity work.score_text 
		port map(
			clk=>clk_50,
			reset=>reset,
			pixel_x=>pixel_x,
			pixel_y=>pixel_y,
			dig3=>dig3,
			dig2=>dig2,
			dig1=>dig1,
			dig0=>dig0,
			text_on=>text_on,
			text_rgb=>text_rgb		
		);
		
process(text_on,text_rgb, background_rgb)
  begin
       -- display score, rule or game over
       if (text_on='1') then
          rgb <= text_rgb;
       else
         rgb <= background_rgb;
       end if;
  end process; 


end my_structural;
