----------------------------------------------------------------------------
-- Description:  Single pulse generator, takes input of arbitrary length and generates a single pulse on the first clk cycle with high input.
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 22, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_patterns is
	generic (
		system_clock_period : time := 20 ns
	);
	port (
		clk					: in	std_ulogic;
		rst					: in	std_ulogic;
		push_button 		: in std_ulogic;
		switches				: in	std_logic;
		hps_led_control	: in boolean;
		base_period 		: in unsigned(7 downto 0);
		led_reg				: in std_ulogic_vector(7 downto 0);
		led					: out	std_ulogic_vector(7 downto 0)
	);
end entity;

