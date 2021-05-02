LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity memory_game is
	port(
    clk_50 : in std_logic; -- connected to 50 MHz clock PIN_AF14;
    btn_one, btn_two, btn_three, btn_four : in std_logic; -- connected to KEY[0..4]
	 power_switch: in std_logic; --connected to the first switch to indicate game starts
	 diff_sw : in std_logic_vector(1 downto 0);
	 leds: out std_logic_vector(3 downto 0); -- LEDR[3 downto 0]
	 input_val: out std_logic -- LEDR[9]
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
begin

btn1 <= not btn_one; --when the button is pressed
btn2 <= not btn_two; --when the button is pressed
btn3 <= not btn_three; --when the button is pressed
btn4 <= not btn_four; --when the button is pressed

reset <= not power_switch; --add ability to turn game off

clk_div_inst : clk_divider port map (clk_50, slowClk, difficulty_const);
alt_pll_inst : my_altpll port map (clk_50, reset, clk); --instance of clk_divider component
lsfr_inst : LFSR port map (slowClk, expire, reset, curr_input); --instance of lsfr to generate new sequences

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

end my_structural;
