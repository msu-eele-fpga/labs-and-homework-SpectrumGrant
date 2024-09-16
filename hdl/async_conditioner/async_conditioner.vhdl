----------------------------------------------------------------------------
-- Description:  Single pulse generator, takes input of arbitrary length and generates a single pulse on the first clk cycle with high input.
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 12, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity async_conditioner is
	port (clk		: in	std_logic;
			rst		: in	std_logic;
			async		: in	std_logic;
			sync		: out	std_logic);
end entity;

architecture async_conditioner_arch of async_conditioner is
	component synchronizer is
		port (
			clk	: in	std_ulogic;
			async	: in	std_ulogic;
			sync	: out	std_ulogic
		);
	end component synchronizer;

	component debouncer
		generic(
			clk_period		: time := 20 ns;
			debounce_time	: time := 100 ms
		);
		port (
			clk				: in	std_logic;
			rst				: in	std_logic;
			input				: in	std_logic;
			debounced		: out	std_logic
		);
	end component debouncer;
	
	component onepulse
		port (
			clk		: in	std_logic;
			rst		: in	std_logic;
			input		: in	std_logic;
			pulse		: out	std_logic
		);
	end component;

	signal synchronizer_output: std_logic;
	signal debounced_output: std_logic;
	
begin
	CMP_SYNCHRONIZER: synchronizer
	port map(
		clk => clk,
		async => async,
		sync => synchronizer_output
	);
	
	CMP_DEBOUNCER: debouncer
	port map(
		clk => clk,
		rst => rst,
		input => synchronizer_output,
		debounced => debounced_output
	);
	
	CMP_ONEPULSE: onepulse
	port map(
		clk => clk,
		rst => rst,
		input => debounced_output,
		pulse => sync
	);
end architecture;