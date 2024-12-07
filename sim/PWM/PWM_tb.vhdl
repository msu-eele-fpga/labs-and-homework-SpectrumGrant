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

entity PWM_tb is
end entity PWM_tb;


architecture PWM_tb_arch of PWM_tb is
constant CLK_PERIOD 		: time := 1 ms;
constant W_DUTY_CYCLE	: integer := 22; -- 22.21;
constant W_PERIOD			: integer := 13;  -- 13.7


signal clk_tb			: std_ulogic := '0';
signal rst_tb			: std_ulogic := '0';
signal period_tb		: unsigned(W_PERIOD -1 downto 0) := "0000011000000";
-- 111         
--	210987 6543210
-- 000001.0000000
-- 
signal duty_cycle_tb	: unsigned(W_DUTY_CYCLE -1 downto 0) := "0010000000000000000000";
signal output_tb		: std_ulogic := '0';


begin
  clk_tb <= not clk_tb after CLK_PERIOD / 2;

	duv : entity work.PWM_Controller
		generic map (
			CLK_PERIOD => 1 ms
		)
		port map (
			clk					=> clk_tb,
			rst					=> rst_tb,
			period 				=> period_tb,
			duty_cycle			=> duty_cycle_tb,
			output				=> output_tb
		);

	stimuli_generator : process is
	begin
		rst_tb <= '1', '0' after 1 ms;
--		push_button_tb <= '0';
		period_tb <= "0000011000000"; -- 1.5s
		duty_cycle_tb <= "0010000000000000000000"; -- 25%
		wait for 10000 ms;
		period_tb <= "0000000001000"; -- 62.5ms
		duty_cycle_tb <= "0010100000000000000000"; -- 31.5%
		wait for 10000 ms;
		period_tb <= "0000000100000"; -- 0.25s
		duty_cycle_tb <= "1110000000000000000000"; -- 175%
		wait for 10000 ms;
	
		std.env.finish;
	end process stimuli_generator;
		
		

end architecture PWM_tb_arch;