-------------------------------------------------------------------------------
--
-- Copyright (c) 2018 Iain Waugh
-- All rights reserved.
--
-------------------------------------------------------------------------------
-- Project Name  : Zedboard
-- Author(s)     : Iain Waugh
-- File Name     : zedboard.vhd
--
-- Top level template for the Avnet Zedboard Zynq 7020 evaluation board.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util_pkg.all;

entity zturn is
  port(
    ----------------------------------------------------------------------------
    -- Clock Source - Bank 13
    clk_100MHz : in std_logic;          -- "GCLK"

    -- User LEDs - Bank 33
    o_led : out std_logic_vector(2 downto 0);  -- "LD[7:0]"

 
    ----------------------------------------------------------------------------
    -- User Push Buttons - Bank 34
    i_btn_c : in std_logic             -- "BTNC"

   
    );
end zturn;

architecture zturn_rtl of zturn is

  signal clk_250mhz : std_logic := '0';
  signal rst_250mhz : std_logic := '1';

  -- Internal timing pulses
  -- 8 = 100ns, 1us, 10us, 100us, 1ms, 10ms, 100ms, 1s
  constant C_POWERS_OF_100NS  : natural := 8;
  signal pulse_at_100ns_x_10e : std_logic_vector(C_POWERS_OF_100NS - 1 downto 0);


 

  

  -- Other system signals
  signal led : std_logic_vector(o_led'range) := (others => '0');

begin  -- zedboard_rtl

  ----------------------------------------------------------------------------
  -- Create system clocks and resets
  u_clk_gen : entity work.clk_gen
    generic map (
      G_CLOCKS_USED    => 2,
      G_CLKIN_PERIOD   => 10.0,         -- 10ns for a 100MHz clock
      G_CLKFBOUT_MULT  => 10,           -- 100MHz x 10 gets a 1GHz internal PLL
      G_CLKOUT0_DIVIDE => 4,            -- o_clk_0 = 1GHz / 4  = 250MHz
      G_CLKOUT1_DIVIDE => 20)           -- o_clk_0 = 1GHz / 20 = 50MHz
    port map (
      -- Clock and Reset input signals
      clk => clk_100mhz,
      rst => '0',  -- No reset input: Reset is determined by the PLL lock

      -- Clock and reset output signals
      o_clk_0 => clk_250mhz,
      o_rst_0 => rst_250mhz,

      o_clk_1 => open,
      o_rst_1 => open,
      o_clk_2 => open,
      o_rst_2 => open,
      o_clk_3 => open,
      o_rst_3 => open,
      o_clk_4 => open,
      o_rst_4 => open,
      o_clk_5 => open,
      o_rst_5 => open);

  ----------------------------------------------------------------------------
  -- Connect 3x buttons to 3x LEDs
  key_c_debounce : entity work.debounce
    generic map (
      G_INVERT_OUTPUT => true)
    port map (
      clk         => clk_250MHz,
      i_button    => i_btn_c,
      i_pulse     => pulse_at_100ns_x_10e(3),
      o_debounced => led(0));


  ----------------------------------------------------------------------------
  -- Make the "Hello  world" LED blink
  u_pulse_gen : entity work.pulse_gen
    generic map (
      -- How many timers do you want?
      G_POWERS_OF_100NS => C_POWERS_OF_100NS,

      -- How many clocks cycles in the 1st 100ns pulse?
      G_CLKS_IN_100NS => 25,            -- for a 100MHz clock

      -- Do you want the output pulses to be aligned with each-other?
      G_ALIGN_OUTPUTS => true)
    port map (
      -- Clock and Reset signals
      clk => clk_250mhz,
      rst => rst_250mhz,

      o_pulse_at_100ns_x_10e => pulse_at_100ns_x_10e);

  u_hello_world : entity work.hello_world
    port map (
      -- Clock and Reset signals
      clk => clk_250mhz,

      i_pulse  => pulse_at_100ns_x_10e(7),
      o_toggle => led(1));

  led(led'high downto 2) <= (others => '0');

  o_led <= led;

end zturn_rtl;
