library ieee;
use ieee.std_logic_1164.all;

entity LFSR is
   port (
      clk : in std_logic; 
      reset : in std_logic;
      z : out std_logic_vector (7 downto 0)
   );
end entity;
 
ARCHITECTURE arc_1_to_many  OF LFSR IS

   CONSTANT seed : std_logic_vector(7 DOWNTO 0) := "01010101"; -- (OTHERS  => '1');
   SIGNAL q : std_logic_vector(7 DOWNTO 0); 
   
BEGIN

   z <= q;
   
   Inst_LFSR : PROCESS(clk, reset)
   BEGIN
      IF (reset = '1') THEN 
         q <= seed;                       -- set seed value on reset
      ELSIF (clk'EVENT AND clk='0') THEN  -- clock with falling edge
         q(0) <= q(7);                    -- feedback to LS bit
         q(1) <= q(0);                                
         q(2) <= q(1) XOR q(7);           -- tap at stage 1
         q(3) <= q(2) XOR q(7);           -- tap at stage 2
         q(4) <= q(3) XOR q(7);           -- tap at stage 3
         q(7 DOWNTO 5) <= q(6 DOWNTO 4);  -- others bits shifted
      END IF;
   END PROCESS;

END ARCHITECTURE;
