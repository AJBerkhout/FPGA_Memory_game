--this component converts an integer to 4 BCD Digits
--it is used for displaying the score

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity m100_counter is
   port(
      clk, reset: in std_logic;
      d_clr: in std_logic;
		score : in integer;
      dig0,dig1,dig2,dig3: out std_logic_vector (3 downto 0)
   );
end m100_counter;

 
architecture arch of m100_counter is
   signal dig0_num, dig1_num, dig2_num, dig3_num: integer;
begin
	process (clk, reset)
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then --reset all the digits back to 0
				dig0_num <= 0;
				dig1_num <= 0;
				dig2_num <= 0;
				dig3_num <= 0;
			else 
				dig3_num <= (score / 1000)MOD 10; --compute the 1000s digit
				dig2_num <= (score / 100) MOD 10; --compute the 100s  digit
				dig1_num <= (score/ 10) MOD 10;   --compute the 10s   digit
				dig0_num <= score MOD 10;         --compute the 1s    digit
        end if;
		end if;
	dig0 <= std_logic_vector(to_unsigned(dig0_num, 4)); --integer -> std_logic_vector with size 4
	dig1 <= std_logic_vector(to_unsigned(dig1_num, 4)); --integer -> std_logic_vector with size 4
	dig2 <= std_logic_vector(to_unsigned(dig2_num, 4)); --integer -> std_logic_vector with size 4
	dig3 <= std_logic_vector(to_unsigned(dig3_num, 4)); --integer -> std_logic_vector with size 4
end process;
end arch;
