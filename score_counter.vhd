-- Listing 13.8
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity m100_counter is
   port(
      clk, reset: in std_logic;
      d_inc, d_clr: in std_logic;
      dig0,dig1,dig2,dig3: out std_logic_vector (3 downto 0)
   );
end m100_counter;

 
architecture arch of m100_counter is
   signal dig0_reg, dig1_reg, dig2_reg, dig3_reg: unsigned(3 downto 0);
   signal dig0_next, dig1_next, dig2_next, dig3_next: unsigned(3 downto 0);
begin
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
			dig3_reg <= (others=>'0');
         dig2_reg <= (others=>'0');
         dig1_reg <= (others=>'0');
         dig0_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
			dig3_reg <= dig3_next;
         dig2_reg <= dig2_next;
         dig1_reg <= dig1_next;
         dig0_reg <= dig0_next;
      end if;
   end process;
   -- next-state logic for the decimal counter
   process(d_clr,d_inc,dig3_reg, dig2_reg, dig1_reg,dig0_reg)
   begin
      dig0_next <= dig0_reg;
      dig1_next <= dig1_reg;
		dig2_next <= dig2_reg;
      dig3_next <= dig3_reg;
      if (d_clr='1') then
         dig0_next <= (others=>'0');
         dig1_next <= (others=>'0');
      elsif (d_inc ='1') then
         if dig0_reg=9 then
            dig0_next <= (others=>'0');
            if dig1_reg=9 then -- 10th digit
               dig1_next <= (others=>'0');
					if dig2_reg=9 then
						dig2_next <= (others=>'0');
						if dig3_reg=9 then
							dig3_next <= (others=>'0');
						else
							dig3_next <= dig3_reg + 1;
						end if;
					else
						dig2_next <= dig2_reg + 1;
					end if;
            else
               dig1_next <= dig1_reg + 1;
            end if;
         else -- dig0 not 9
            dig0_next <= dig0_reg + 1;
         end if;
      end if;
   end process;
   dig0 <= std_logic_vector(dig0_reg);
   dig1 <= std_logic_vector(dig1_reg);
	dig2 <= std_logic_vector(dig2_reg);
	dig3 <= std_logic_vector(dig3_reg);
end arch;
