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

entity onepulse_tb is
end entity onepulse_tb;


architecture onepulse_tb_arch of onepulse_tb is

signal clk_tb		: std_ulogic := '0';
signal rst_tb		: std_ulogic := '0';
signal input_tb	: std_ulogic := '0';
signal pulse_tb	: std_ulogic := '0';


begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;

	duv : entity work.onepulse
		port map (
			clk	=> clk_tb,
			rst	=> rst_tb,
			input	=> input_tb,
			pulse	=> pulse_tb
		);

	stimuli_generator : process is
	begin
		rst_tb <= '1', '0' after 50 ns;

		input_tb <= '0';
		wait for 60 ns;
		
		print("----------------------------------------------------");
      print("Testing 3-clock cycle pulses");
      print("----------------------------------------------------");
		for i in 1 to 40 loop
			input_tb <= not input_tb; wait for 60 ns;
		end loop;
		print("----------------------------------------------------");
      print("Testing single-clock cycle pulses");
      print("----------------------------------------------------");
		for i in 1 to 40 loop
			input_tb <= not input_tb; wait for 20 ns;
		end loop;
		print("----------------------------------------------------");
      print("Testing sub-clock cycle pulses");
      print("----------------------------------------------------");
		for i in 1 to 40 loop
			input_tb <= not input_tb; wait for 10 ns;
		end loop;
		
		print("----------------------------------------------------");
      print("Testing varying-cycle clock pulses");
      print("----------------------------------------------------");
		for i in 1 to 40 loop
			input_tb <= not input_tb; wait for 94 ns;
			input_tb <= not input_tb; wait for 71 ns;
			input_tb <= not input_tb; wait for 44 ns;
			input_tb <= not input_tb; wait for 58 ns;
			input_tb <= not input_tb; wait for 52 ns;
			input_tb <= not input_tb; wait for 86 ns;
			input_tb <= not input_tb; wait for 71 ns;
			input_tb <= not input_tb; wait for 11 ns;
			input_tb <= not input_tb; wait for 56 ns;
			input_tb <= not input_tb; wait for 58 ns;
		end loop;

		std.env.finish;
	end process stimuli_generator;
		
		

end architecture onepulse_tb_arch;