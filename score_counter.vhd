-- Listing 13.8
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity m100_counter is
   port(
      clk, reset: in std_logic;
      d_inc, d_clr: in std_logic;
		score : in integer;
      dig0,dig1,dig2,dig3: out std_logic_vector (3 downto 0)
   );
end m100_counter;

 
architecture arch of m100_counter is
   signal dig0_num, dig1_num, dig2_num, dig3_num: integer;
	signal binary_score : std_logic_vector(14 downto 0);
begin
	process (clk, reset)
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				dig0_num <= 0;
				dig1_num <= 0;
				dig2_num <= 0;
				dig3_num <= 0;
			else 
				dig3_num <= (score / 1000)MOD 10;
				dig2_num <= (score / 100) MOD 10;
				dig1_num <= (score/ 10) MOD 10;
				dig0_num <= score MOD 10;
        end if;
		end if;
	dig0 <= std_logic_vector(to_unsigned(dig0_num, 4));
	dig1 <= std_logic_vector(to_unsigned(dig1_num, 4));
	dig2 <= std_logic_vector(to_unsigned(dig2_num, 4));
	dig3 <= std_logic_vector(to_unsigned(dig3_num, 4));
end process;
   -- registers
--   process (clk,reset)
--   begin
--      if reset='1' then
--			dig3_reg <= (others=>'0');
--         dig2_reg <= (others=>'0');
--         dig1_reg <= (others=>'0');
--         dig0_reg <= (others=>'0');
--      elsif (clk'event and clk='1') then
--			dig3_reg <= dig3_next;
--         dig2_reg <= dig2_next;
--         dig1_reg <= dig1_next;
--         dig0_reg <= dig0_next;
--      end if;
--   end process;
--   -- next-state logic for the decimal counter
--   process(d_clr,d_inc,dig3_reg, dig2_reg, dig1_reg,dig0_reg)
--   begin
--      dig0_next <= dig0_reg;
--      dig1_next <= dig1_reg;
--		dig2_next <= dig2_reg;
--      dig3_next <= dig3_reg;
--      if (d_clr='1') then
--         dig0_next <= (others=>'0');
--         dig1_next <= (others=>'0');
--      elsif (d_inc ='1') then
--         if dig0_reg=9 then
--            dig0_next <= (others=>'0');
--            if dig1_reg=9 then -- 10th digit
--               dig1_next <= (others=>'0');
--					if dig2_reg=9 then
--						dig2_next <= (others=>'0');
--						if dig3_reg=9 then
--							dig3_next <= (others=>'0');
--						else
--							dig3_next <= dig3_reg + 1;
--						end if;
--					else
--						dig2_next <= dig2_reg + 1;
--					end if;
--            else
--               dig1_next <= dig1_reg + 1;
--            end if;
--         else -- dig0 not 9
--            dig0_next <= dig0_reg + 1;
--         end if;
--      end if;
--   end process;
end arch;
