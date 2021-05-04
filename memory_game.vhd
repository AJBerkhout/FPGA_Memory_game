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
signal curr_input : std_logic_Vector(3 downto 0) := "0000";
signal input_done: std_logic := '0';
signal input_success : std_logic := '0';
signal score_inst : integer;
signal time_out : integer := 100;
signal score : integer;
signal difficulty_const : integer := 22;
signal expire : std_logic := '0';
signal counter : integer := 0;

signal video_on, pixel_tick: std_logic;
signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
signal rgb : std_logic_vector(2 downto 0);
begin


color_map_inst : color_map port map ("0000", rgb, vga_r, vga_g, vga_b);
btn1 <= not btn_one; --when the button is pressed
btn2 <= not btn_two; --when the button is pressed
btn3 <= not btn_three; --when the button is pressed
btn4 <= not btn_four; --when the button is pressed

reset <= not power_switch; --add ability to turn game off

clk_div_inst : clk_divider port map (clk_50, slowClk, difficulty_const);
alt_pll_inst : my_altpll port map (clk_50, reset, clk); --instance of clk_divider component
lsfr_inst : LFSR port map (slowClk, expire, reset, curr_input); --instance of lsfr to generate new sequences

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

leds <= curr_input; --output the expected sequence to the leds
--input handler component instance
input_handler_inst : input_handler port map (btn1, btn2, btn3, btn4, reset, clk_50, expire, curr_input, input_done, input_success, score_inst);

process (score_inst)
begin
	input_val <= input_success;
	score <= score + score_inst;
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
      rgb => rgb
		);


end my_structural;
