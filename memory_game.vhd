LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity memory_game is
	port(
    clk_50 : in std_logic; -- connected to 50 MHz clock PIN_AF14;
    btn_one, btn_two, btn_three, btn_four : in std_logic; -- connected to KEY[0..4]
	 power_switch: in std_logic; --connected to the first switch to indicate game starts
    -- seven_seg : out std_logic_vector(7 downto 0);
	 leds: out std_logic_vector(3 downto 0);
	 input_val: out std_logic
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
	  --time_out: in std_logic(8 downto 0);
	  expected_input: in std_logic_vector(3 downto 0);
	  done: out std_logic;
	  success: out std_logic
     --score_update: out std_logic_vector(8 downto 0);
	);
end component;

COMPONENT my_altpll 
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic         -- outclk0.clk
	);
END COMPONENT;

signal clk : std_logic; -- internal signal set by clock divider output
signal btn1, btn2, btn3, btn4 : std_logic; -- internal signal for the buttons
signal tick1, tick2, tick3, tick4 : std_logic; -- internal signal for the buttons
signal reset : std_logic;
signal random_led_output : std_logic_Vector(3 downto 0);
signal input_done: std_logic := '1';
signal input_success : std_logic;
begin

btn1 <= not btn_one; --when the button is pressed
btn2 <= not btn_two; --when the button is pressed
btn3 <= not btn_three; --when the button is pressed
btn4 <= not btn_four; --when the button is pressed
reset <= not power_switch;
alt_pll_inst : my_altpll port map (clk_50, reset, clk); --instance of clk_divider component
--edge_detect_inst1 : edge_detect port map (clk, reset, btn1, tick1);
--edge_detect_inst2 : edge_detect port map (clk, reset, btn2, tick2);
--edge_detect_inst3 : edge_detect port map (clk, reset, btn3, tick3);
--edge_detect_inst4 : edge_detect port map (clk, reset, btn4, tick4);
lsfr_inst : LFSR port map (clk, input_done, reset, random_led_output);

leds <= random_led_output;
-- input validator state machine
-- states :idle state, received input state, stopped state

-- inputs: (tick1, tick2, tick3, tick4), clk, random_led, started_switch, reset_switch
-- outputs: updated score
input_handler_inst : input_handler port map (btn1, btn2, btn3, btn4, reset, clk, random_led_output, input_done, input_val);

-- sequence generator
-- states: generating, full
-- inputs: fifo; outputs: updated fifo

end my_structural;
