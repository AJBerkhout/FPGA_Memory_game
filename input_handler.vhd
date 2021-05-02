library ieee;
use ieee.std_logic_1164.all;

entity input_handler is
  port(
    tick1, tick2, tick3, tick4: in std_logic;
	 reset: in std_logic;
    clk: in std_logic;
	 timer_clk : in std_logic;
	 time_out: in integer;
	 expected_input: in std_logic_vector(3 downto 0);
	 done: out std_logic;
	 success: out std_logic;
    score_update: out integer
	 
  );
end input_handler;

architecture MEALY_ARCHITECTURE of input_handler is

	type state_type is (waiting_input, validating_input); --state tracking
	signal state_current, state_next : state_type := waiting_input; --initializing to waiting
	signal received_input: std_logic_vector (3 downto 0); --for what input was received
	signal internal_done : std_logic := '0';  --internal signal indicating whether an input was received
	signal internal_success: std_logic := '0'; --internal signal for whether to input was correct
	signal combo : integer := 0;
	
	signal counter : integer := 0;
	begin
		-- state register; process #1
		process (clk, reset)
		begin
		   received_input(0) <= tick1; --update the received input with new ticks
			received_input(1) <= tick2;
			received_input(2) <= tick3;
			received_input(3) <= tick4;
			if (reset = '1') then  --reset to waiting
				state_current <= waiting_input;
			elsif (clk' event and clk = '1') then
				state_current <= state_next;
			end if;
	   end process;
    	
		-- next state and output logic; process #2
		process (state_current, expected_input, timer_clk)
		begin
			state_next <= state_current;
			case state_current is 
				when waiting_input =>
				
					internal_done <= '0'; --reset success and done while waiting
					internal_success <= '0';
					if (timer_clk' event and timer_clk = '1') then
						counter <= counter + 1;
					end if;
					if (time_out <= counter) then
						internal_success <= '0';
						score_update <= 0;
						combo <= 0;
						state_next <= validating_input;
					elsif (received_input = "0000") then --no input received
						state_next <= waiting_input; --continue waiting
					else
						state_next <= validating_input; --otherwise move to validating
						if (received_input = expected_input) then --check whether input was correct
							internal_success <= '1';
							combo <= combo + 1;
							score_update <= combo;
						else
							internal_success <= '0';
							score_update <= 0;
							combo <= 0;
						end if;
					end if;
				when validating_input =>
					counter <= 0;
					if (received_input = "0000") then --button has been deselected
						internal_done <= '1'; --process is currently done
						state_next <= waiting_input;	 --move to waiting for next input
					else
						state_next <= validating_input; --otherwise, keep validating
					end if;
			end case;
		done <= internal_done; --return the done and success status
		success <= internal_success;
		end process;
end MEALY_ARCHITECTURE;	
