-------------------------------------------------------------------------------
--
-- Copyright (c) 2021 Iain Waugh, CadHut. All rights reserved.
-- 
-- This code is a sample and does not come with any warranty or guarantee of correctness.
-- Redistribution and use in source and binary forms (with or without
-- modification) is permitted.
--
-------------------------------------------------------------------------------
-- Project Name  : FPGA Dev Board Project
-- Author(s)     : Iain
-- File Name     : counters.vhd
--
-- 4 different ways to count up/down some 'n' number of times
--  if (count <= number) then count else reset
--  if (count >  number) then reset else count
--  if (count >  0)      then count else reset
--  if (count =  0)      then reset else count
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_up_lte_num is
  generic (
    G_WIDTH : natural := 12
    );
  port(
    -- Clock and Reset signals
    clk : in std_logic;
    rst : in std_logic;

    -- Other signals
    i_number : in  unsigned(G_WIDTH - 1 downto 0);
    o_done   : out std_logic
    );
end count_up_lte_num;

architecture count_up_lte_num_rtl of count_up_lte_num is
  -- Internal signals
  signal count : unsigned(i_number'range);
  signal done  : std_logic;

begin  -- count_up_lte_num_rtl

  ----------------------------------------------------------------------
  -- Count up: check "<="
  u_count_up_lte_num : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        count <= (others => '0');
        done  <= '0';
      else
        if (count <= i_number) then
          count <= count + 1;
          done  <= '0';
        else
          count <= (others => '0');
          done  <= '1';
        end if;
      end if;
    end if;
  end process;
  o_done <= done;

end count_up_lte_num_rtl;


-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_up_gt_num is
  generic (
    G_WIDTH : natural := 12
    );
  port(
    -- Clock and Reset signals
    clk : in std_logic;
    rst : in std_logic;

    -- Other signals
    i_number : in  unsigned(G_WIDTH - 1 downto 0);
    o_done   : out std_logic
    );
end count_up_gt_num;

architecture count_up_gt_num_rtl of count_up_gt_num is
  -- Internal signals
  signal count : unsigned(i_number'range);
  signal done  : std_logic;

begin  -- count_up_lte_num_rtl

  ----------------------------------------------------------------------
  -- Count up: check ">"
  u_count_up_gt_num : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        count <= (others => '0');
        done  <= '0';
      else
        if (count > i_number) then
          count <= (others => '0');
          done  <= '1';
        else
          count <= count + 1;
          done  <= '0';
        end if;
      end if;
    end if;
  end process;
  o_done <= done;

end count_up_gt_num_rtl;


-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_dn_eq_zero is
  generic (
    G_WIDTH : natural := 12
    );
  port(
    -- Clock and Reset signals
    clk : in std_logic;
    rst : in std_logic;

    -- Other signals
    i_number : in  unsigned(G_WIDTH - 1 downto 0);
    o_done   : out std_logic
    );
end count_dn_eq_zero;

architecture count_dn_eq_zero_rtl of count_dn_eq_zero is
  -- Internal signals
  signal count : unsigned(i_number'range);
  signal done  : std_logic;

begin  -- count_up_lte_num_rtl

  ----------------------------------------------------------------------
  -- Count down: check " = 0"
  u_count_dn_eq_zero : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        count <= i_number;
        done  <= '0';
      else
        if (count = 0) then
          count <= i_number;
          done  <= '1';
        else
          count <= count - 1;
          done  <= '0';
        end if;
      end if;
    end if;
  end process;
  o_done <= done;

end count_dn_eq_zero_rtl;


-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_dn_gt_zero is
  generic (
    G_WIDTH : natural := 12
    );
  port(
    -- Clock and Reset signals
    clk : in std_logic;
    rst : in std_logic;

    -- Other signals
    i_number : in  unsigned(G_WIDTH - 1 downto 0);
    o_done   : out std_logic
    );
end count_dn_gt_zero;

architecture count_dn_gt_zero_rtl of count_dn_gt_zero is
  -- Internal signals
  signal count : unsigned(i_number'range);
  signal done  : std_logic;

begin  -- count_up_lte_num_rtl

  ----------------------------------------------------------------------
  -- Count up: check " > 0"
  u_count_dn_gt_zero : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        count <= i_number;
        done  <= '0';
      else
        if (count > 0) then
          count <= count - 1;
          done  <= '0';
        else
          count <= i_number;
          done  <= '1';
        end if;
      end if;
    end if;
  end process;
  o_done <= done;

end count_dn_gt_zero_rtl;


-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counters is
  generic (
    G_WIDTH : natural := 5
    );
  port(
    -- Clock and Reset signals
    clk : in std_logic;
    rst : in std_logic;

    -- Other signals
    i_number_a : in unsigned(G_WIDTH - 1 downto 0);
    i_number_b : in unsigned(G_WIDTH - 1 downto 0);
    i_number_c : in unsigned(G_WIDTH - 1 downto 0);
    i_number_d : in unsigned(G_WIDTH - 1 downto 0);

    o_done_a : out std_logic;
    o_done_b : out std_logic;
    o_done_c : out std_logic;
    o_done_d : out std_logic
    );
end counters;

architecture counters_rtl of counters is
  -- Internal signals

begin -- count_top_rtl

  u_count_up_lte_num : entity work.count_up_lte_num
    generic map (
      G_WIDTH => G_WIDTH)
    port map (
      -- Clock and Reset signals
      clk => clk,
      rst => rst,

      -- Other signals
      i_number => i_number_a,
      o_done   => o_done_a);

  u_count_up_gt_num : entity work.count_up_gt_num
    generic map (
      G_WIDTH => G_WIDTH)
    port map (
      -- Clock and Reset signals
      clk => clk,
      rst => rst,

      -- Other signals
      i_number => i_number_b,
      o_done   => o_done_b);

  u_count_dn_gt_zero : entity work.count_dn_gt_zero
    generic map (
      G_WIDTH => G_WIDTH)
    port map (
      -- Clock and Reset signals
      clk => clk,
      rst => rst,

      -- Other signals
      i_number => i_number_c,
      o_done   => o_done_c);

  u_count_dn_eq_zero : entity work.count_dn_eq_zero
    generic map (
      G_WIDTH => G_WIDTH)
    port map (
      -- Clock and Reset signals
      clk => clk,
      rst => rst,

      -- Other signals
      i_number => i_number_d,
      o_done   => o_done_d);

end counters_rtl;
