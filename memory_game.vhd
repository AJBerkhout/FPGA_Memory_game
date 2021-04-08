LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity fpga_hero is
	port(
    clk_50 : in std_logic; -- connected to 50 MHz clock PIN_AF14;
    btn_one, btn_two, btn_three, btn_four : in std_logic; -- connected to KEY[0..4]
	 power_switch: in std_logic; --connected to the first switch to indicate game starts
    seven_seg : out std_logic_vector(7 downto 0);
	 leds: out std_logic_vector(3 downto 0);
	 
  );
end fpga_hero;

architecture my_structural of fpga_hero is
--port mapping for the clk_divider internal component
component clk_divider is
  port ( 
    CLK_IN : in STD_LOGIC;
    CLK_OUT : out STD_LOGIC
  );
end component;

component LFSR 
  port (
    clk : in std_logic; 
    reset : in std_logic;
    z : out std_logic_vector (7 downto 0)
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

signal clk : std_logic; -- internal signal set by clock divider output
signal btn1, btn2, btn3, btn4 : std_logic; -- internal signal for the buttons
signal tick1, tick2, tick3, tick4 : std_logic; -- internal signal for the buttons
signal reset : std_logic;
signal random_led_output : std_logic_Vector(1 downto 0);
begin

btn1 <= not btn_one; --when the button is pressed
btn2 <= not btn_two; --when the button is pressed
btn3 <= not btn_three; --when the button is pressed
btn4 <= not btn_four; --when the button is pressed

clock_divider_inst : clk_divider port map (clk_50, clk); --instance of clk_divider component
edge_detect_inst1 : edge_detect port map (clk, reset, btn1, tick1);
edge_detect_inst2 : edge_detect port map (clk, reset, btn2, tick2);
edge_detect_inst3 : edge_detect port map (clk, reset, btn3, tick3);
edge_detect_inst4 : edge_detect port map (clk, reset, btn4, tick4);
lsfr_inst : lsft port map (clk, reset, random_led_output);

-- input validator state machine
-- states :idle state, received input state, stopped state

-- inputs: (tick1, tick2, tick3, tick4), clk, random_led, started_switch, reset_switch
-- outputs: updated score


-- sequence generator
-- states: generating, full
-- inputs: fifo; outputs: updated fifo




end my_structural;