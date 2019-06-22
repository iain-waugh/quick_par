-------------------------------------------------------------------------------
--
-- Copyright (c) 2019 Iain Waugh. All rights reserved.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_prbs23 is
end entity tb_prbs23;

architecture tb_prbs23_rtl of tb_prbs23 is

  signal clk     : std_logic := '0';
  signal rst     : std_logic := '0';
  signal o_prbs1 : std_logic;
  signal o_prbs2 : std_logic;

  signal o_prbs1_delay : std_logic;
  
begin  -- architecture tb_prbs23_rtl

  -- Component instantiations
  DUT1 : entity work.prbs23
    port map (
      clk    => clk,
      rst    => rst,
      o_prbs => o_prbs1);

  DUT2 : entity work.prbs23_small
    port map (
      clk    => clk,
      o_prbs => o_prbs2);

  -- Make a delay-matched version for comparison
  o_prbs1_delay <= transport o_prbs1 after 380 ns;

  -------------------------------------------------------------------------------
  -- System clock generation
  clk_gen : process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process clk_gen;

  -----------------------------------------------------------------------------
  -- Reset generation
  rst_gen : process
  begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait;
  end process rst_gen;

end architecture tb_prbs23_rtl;
