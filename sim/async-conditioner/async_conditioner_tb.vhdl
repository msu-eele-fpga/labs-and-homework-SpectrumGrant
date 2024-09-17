----------------------------------------------------------------------------
-- Description:  Asynchronous conditioner testbench
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 12, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library ieee;
library osvvm;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;
use osvvm.randompkg.all;

entity async_conditioner_tb is
end entity;

architecture async_conditioner_tb_arch of async_conditioner_tb is
	signal clk_tb		: std_ulogic := '0';
	signal rst_tb		: std_ulogic := '0';
	signal async_tb	: std_ulogic := '0';
	signal sync_tb		: std_ulogic := '0';

	signal hold_track	: std_ulogic := '0';

begin
	clk_tb <= not clk_tb after CLK_PERIOD / 2;
	
	duv : entity work.async_conditioner
		port map (
			clk	=> clk_tb,
			rst	=> rst_tb,
			async	=> async_tb,
			sync	=> sync_tb
		);
		
			
	stimuli_generator : process is
		variable RV		: RandomPType;
		variable hold_time : Time;
	begin
		RV.InitSeed(RV'instance_name);
		
		rst_tb <= '1', '0' after 50 ns;
		
		for i in 1 to 40 loop
			async_tb <= not async_tb;
			wait for RV.RandTime(10 ms, 400 ms);
		end loop;	
		
		std.env.finish;
	end process stimuli_generator;

	hold_time : process is
	begin
		if (sync_tb = '1') then
			hold_track <= '1';
			wait for 100 ms;
			hold_track <= '0';
		end if;
	end process;
	
	
	response_checker : process is
	begin
		if (rising_edge(clk_tb) and async_tb = '1') then
			wait_for_clock_edge(clk_tb);
			assert_eq(sync_tb, '1', "clock cycle after high");
			wait_for_clock_edge(clk_tb);
			assert_eq(sync_tb, '0', "sync low after high");
			wait for 100 ms;
		end if;
	
	end process;
	
end architecture;