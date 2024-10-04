----------------------------------------------------------------------------
-- Description:  Single pulse generator, takes input of arbitrary length and generates a single pulse on the first clk cycle with high input.
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 22, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity led_patterns is
	generic (
		system_clock_period : time := 20 ns
	);
	port (
		clk					: in std_ulogic;
		rst					: in std_ulogic;
		push_button 		: in std_ulogic;
		switches				: in std_ulogic_vector(3 downto 0);
		hps_led_control	: in boolean;
		base_period 		: in unsigned(7 downto 0);
		led_reg				: in std_ulogic_vector(7 downto 0);
		led					: out	std_ulogic_vector(7 downto 0)
	);
end entity;

architecture led_patterns_arch of led_patterns is
	component async_conditioner is
	generic(
		clk_period		: time := 20 ns;
		debounce_time	: time := 100 ms
	);
	port (clk		: in	std_ulogic;
			rst		: in	std_ulogic;
			async		: in	std_ulogic;
			sync		: out	std_ulogic);
	end component async_conditioner;
	
	component led_patterns_state_machine is
	generic (
		system_clock_period : time := 20 ns
	);
	port (
		clk					: in std_ulogic;
		rst					: in std_ulogic;
		push_button 		: in std_ulogic;
		switches				: in std_ulogic_vector(3 downto 0);
		hps_led_control	: in boolean;
		base_period 		: in unsigned(7 downto 0);
		led_reg				: in std_ulogic_vector(7 downto 0);
		led					: out	std_ulogic_vector(7 downto 0)
	);
	end component led_patterns_state_machine;

	signal synchronized_output : std_ulogic;

begin
	CMP_ASYNC : async_conditioner
	generic map (
		clk_period => system_clock_period,
		debounce_time => 100 ms
	)
	port map(
		clk => clk,
		rst => rst,
		async => push_button,
		sync => synchronized_output
	);

	CMP_LED_MACHINE : led_patterns_state_machine
	generic map(
		system_clock_period => system_clock_period
	)
	port map(
		clk => clk,
		rst => rst,
		push_button => synchronized_output,
		switches => switches,
		hps_led_control => hps_led_control,
		base_period => base_period,
		led_reg => led_reg,
		led => led
	);
	
end architecture;