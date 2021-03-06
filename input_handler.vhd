--component for handling the inputs to the game and updating the score

library ieee;
use ieee.std_logic_1164.all;

entity input_handler is
  port(
    tick1, tick2, tick3, tick4: in std_logic;
	 reset: in std_logic;
    clk: in std_logic;
	 expire : in std_logic;
	 expected_input: in std_logic_vector(3 downto 0);
	 done: out std_logic;
	 success: out std_logic;
	 out_combo : out integer;
    score_update: out integer

  );
end input_handler;

architecture MEALY_ARCHITECTURE of input_handler is

	type state_type is (waiting_input, validating_input); --state tracking
	signal state_current, state_next : state_type := waiting_input; --initializing to waiting
	signal received_input: std_logic_vector (3 downto 0); --for what input was received
	signal internal_done : std_logic := '0';  --internal signal indicating whether an input was received
	signal internal_success, internal_fail: std_logic := '0'; --internal signal for whether to input was correct
	signal prev_input : std_logic_vector (3 downto 0) := "0000";
	signal combo : integer := 1;
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
		
		--process for tracking the current combo
		process(clk, internal_success, internal_fail) 
			variable combo_up, combo_down : std_logic := '0';
		begin
			if (internal_success = '1') then --if a successful input was received
				combo_up := '1';              --queue a combo increase
			elsif (internal_fail = '1') then --if a failure was hit 
				combo_down := '1';            --queue a combo reset
			else
				if(clk'event and clk = '1') then              --on the rising edge
					if (combo_up = '1' and combo < 9) then     --if the combo should increase, and isnt capped
						combo <= combo + 1;                     --increase the combo 
					elsif (combo_up = '1' and combo >= 9) then --if it is capped
						combo <= combo;                         --combo remains the same
					elsif (combo_down = '1') then              --combo reset
						combo <= 1;
					end if;
					combo_up := '0';
					combo_down := '0';
				end if;
			end if;

		end process;
		
		-- next state and output logic; process #2
		process (state_current, expected_input, expire)
		begin
			state_next <= state_current;
			case state_current is 
				when waiting_input =>
				
					internal_done <= '0'; --reset success, done, fail and score_update while waiting
					internal_success <= '0';
					internal_fail <= '0';
					score_update <= 0;
					
					if (expire = '1') then      --if an input was not received before the timeout
						internal_success <= '0'; --this is a failure
						score_update <= 0;
						internal_fail <= '1';
						state_next <= waiting_input;
					elsif (received_input = "0000") then --no input received
						state_next <= waiting_input;      --continue waiting
					else
						state_next <= validating_input; --otherwise move to validating
						internal_done <= '1';           --process is currently done
						if (received_input = expected_input and received_input /= "0000") then --check whether input was correct
							internal_success <= '1';
							internal_fail <= '0';
							score_update <= combo;  --increase the score by the combo
						else                       --the input was incorrect
							internal_success <= '0';
							internal_fail <= '1';   --this means its a failure
							score_update <= 0;
							state_next <= validating_input;
						end if;
					end if;
				when validating_input => 
					if (expire = '1') then           --keep in the holding state until the next input is available
						state_next <= waiting_input;  
					else
						state_next <= validating_input;
					end if;
				end case;
		done <= internal_done; --return the done and success status
		success <= internal_success;
		out_combo <= combo;    --return the updated combo
		end process;
end MEALY_ARCHITECTURE;	
