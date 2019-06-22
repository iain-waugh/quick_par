-------------------------------------------------------------------------------
--
-- Copyright (c) 2019 Iain Waugh. All rights reserved.
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util_pkg.all;

entity prbs23_small is
  port(
    -- Clock and Reset signals
    clk    : in  std_logic;
    o_prbs : out std_logic
    );
end prbs23_small;

architecture prbs23_small_rtl of prbs23_small is

  signal sreg       : std_logic_vector(23 - 1 downto 0) := (others => '0');
  signal sreg_in    : std_logic;
  signal sreg_is_0s : std_logic;
  signal count      : unsigned (clog2(23) - 1 downto 0) := (others => '0');

begin  -- prbs23_small_rtl

  -- Taps for PRBS23_SMALL from XAPP052
  -- Mux the taps or shift in the reset value
  sreg_in <= '1' when sreg_is_0s = '1' else sreg(23 - 1) xor sreg(18 - 1);
  process (clk)
  begin
    if (rising_edge(clk)) then
      sreg <= sreg(23 - 1 - 1 downto 0) & sreg_in;
    end if;
  end process;
  o_prbs <= sreg(sreg'high);

  process (clk)
  begin
    if (rising_edge(clk)) then
      if (sreg(sreg'high) = '1') then
        count      <= (others => '0');
        sreg_is_0s <= '0';
      else
        if (count = to_unsigned(23, count'length)) then
          sreg_is_0s <= '1';
        else
          sreg_is_0s <= '0';
          count      <= count + 1;
        end if;
      end if;
    end if;
  end process;

end prbs23_small_rtl;
