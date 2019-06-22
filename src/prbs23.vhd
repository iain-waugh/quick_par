-------------------------------------------------------------------------------
--
-- Copyright (c) 2019 Iain Waugh. All rights reserved.
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util_pkg.zeros;

entity prbs23 is
  port(
    -- Clock and Reset signals
    clk : in std_logic;
    rst : in std_logic;

    -- Other signals
    o_prbs : out std_logic
    );
end prbs23;

architecture prbs23_rtl of prbs23 is

  signal sreg : std_logic_vector(22 downto 0) := (others => '0');

begin  -- prbs23_rtl

  -- Taps for PRBS23 from XAPP052
  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        sreg <= (others => '1');
      else
        if (sreg = zeros(sreg)) then
          sreg <= (others => '1');
        else
          sreg <= sreg(sreg'high - 1 downto 0) &
                  (sreg(22) xor sreg(17));
        end if;
      end if;
    end if;
  end process;
  o_prbs <= sreg(sreg'high);

end prbs23_rtl;
