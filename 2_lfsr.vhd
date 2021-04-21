library ieee;
use ieee.std_logic_1164.all;

entity LFSR is
   port (
      clk : in std_logic;
		gen_next: in std_logic;
      reset : in std_logic;
      z : out std_logic_vector (3 downto 0)
   );
end entity;
 
ARCHITECTURE arc_1_to_many  OF LFSR IS

   CONSTANT seed : std_logic_vector(7 DOWNTO 0) := "00000001"; -- (OTHERS  => '1');
   SIGNAL q : std_logic_vector(7 DOWNTO 0); 
	SIGNAL x : std_logic_vector(3 DOWNTO 0);
   
BEGIN

   z <= x;
   
   Inst_LFSR : PROCESS(gen_next, reset)
   BEGIN
      IF (reset = '1') THEN 
         q <= seed; 	-- set seed value on reset
      --ELSIF (clk'EVENT AND clk='0') THEN  -- clock with falling edge
		elsif (gen_next = '1') then
			q(0) <= q(7);                    -- feedback to LS bit
         q(1) <= q(0);                                
         q(2) <= q(1) XOR q(7);           -- tap at stage 1
         q(3) <= q(2) XOR q(7);           -- tap at stage 2
         q(4) <= q(3) XOR q(7);           -- tap at stage 3
         q(7 DOWNTO 5) <= q(6 DOWNTO 4);  -- others bits shifted
			
		END IF;
		case q(1 downto 0) is
			when "00" =>
				x <= "0001";
			when "01" =>
				x <= "0010";
			when "10" =>
				x <= "0100";
			when "11" =>
				x <= "1000";
		end case;
   END PROCESS;

END ARCHITECTURE;
