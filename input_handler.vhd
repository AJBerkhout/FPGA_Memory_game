library ieee;
use ieee.std_logic_1164.all;

entity input_handler is
  port(
    tick1, tick2, tick3, tick4: in std_logic;
	 reset: in std_logic;
    clk: in std_logic;
	 --time_out: in std_logic(8 downto 0);
	 expected_input: in std_logic_vector(3 downto 0);
	 done: out std_logic;
	 success: out std_logic
    --score_update: out std_logic_vector(8 downto 0);
  );
end input_handler;

architecture MEALY_ARCHITECTURE of input_handler is

	type state_type is (waiting_input, validating_input);
	signal state_current, state_next : state_type := waiting_input;
	signal received_input: std_logic_vector (3 downto 0);
	signal input_to_validate: std_logic_vector(3 downto 0);
	signal internal_done : std_logic := '0';
	signal internal_success: std_logic := '0';
	begin
  
      
		-- state register; process #1
		process (clk , reset)
		begin
		   received_input(0) <= tick1;
			received_input(1) <= tick2;
			received_input(2) <= tick3;
			received_input(3) <= tick4;
			if (reset = '1') then 
				state_current <= waiting_input;
			elsif (clk' event and clk = '1') then 
				state_current <= state_next;
			end if;
	  end process;
    
		-- next state and output logic; process #2
		process (state_current, received_input)
		begin
			state_next <= state_current;
			case state_current is 
				when waiting_input =>
				   internal_done <= '0';
					internal_success <= '0';
					if (received_input = "0000") then
						state_next <= waiting_input;
					else 
						input_to_validate <= received_input;
						state_next <= validating_input;
					end if;
				when validating_input =>
					state_next <= waiting_input;
					internal_done <= '1';
					if (input_to_validate = expected_input) then
						internal_success <= '1';
					else
						internal_success <= '0';
					end if;	
			end case;
		done <= internal_done;
		success <= internal_success;
		end process;
end MEALY_ARCHITECTURE;	
