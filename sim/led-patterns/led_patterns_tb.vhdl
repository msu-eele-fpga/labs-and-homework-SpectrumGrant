----------------------------------------------------------------------------
-- Description:  One pulse test bench
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 13, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity led_patterns_tb is
end entity led_patterns_tb;


architecture led_patterns_tb_arch of led_patterns_tb is

signal clk_tb			: std_ulogic := '0';
signal rst_tb			: std_ulogic := '0';
signal push_button_tb: std_ulogic := '0';
signal hps_led_control_tb: boolean := false;
signal switches_tb	: std_ulogic_vector(3 downto 0) := "0000";
signal base_period_tb: unsigned(7 downto 0) := "00010000";
signal led_reg_tb		: std_ulogic_vector(7 downto 0) := "00000000";
signal led_tb			: std_ulogic_vector(7 downto 0) := "00000000";

constant CLK_PERIOD : time := 10 ms;

begin
  clk_tb <= not clk_tb after CLK_PERIOD / 2;

	duv : entity work.led_patterns
		generic map (
			system_clock_period => 10 ms
		)
		port map (
			clk					=> clk_tb,
			rst					=> rst_tb,
			push_button 		=> push_button_tb,
			switches				=> switches_tb,
			hps_led_control	=> hps_led_control_tb,
			base_period 		=> base_period_tb,
			led_reg				=> led_reg_tb,
			led					=> led_tb
		);

	stimuli_generator : process is
	begin
		rst_tb <= '1', '0' after 50 ns;
--		push_button_tb <= '0';
		wait for 50 ns;

		print("----------------------------------------------------");
      print("Testing switch display");
      print("----------------------------------------------------");
		switches_tb <= "0000";
		push_button_tb <= '1', '0' after 10 ms;		
		wait for 2.5 sec;
		switches_tb <= "0001";
		push_button_tb <= '1', '0' after 10 ms;		
		wait for 2.5 sec;
		switches_tb <= "0010";
		push_button_tb <= '1', '0' after 10 ms;		
		wait for 2.5 sec;
		switches_tb <= "0011";
		push_button_tb <= '1', '0' after 10 ms;		
		wait for 2.5 sec;

		std.env.finish;
	end process stimuli_generator;
		
		

end architecture led_patterns_tb_arch;