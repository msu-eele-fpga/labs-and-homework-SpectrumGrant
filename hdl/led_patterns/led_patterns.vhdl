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
	type state_type is (switch_display, pattern_00, pattern_01, pattern_02, pattern_03, pattern_04);
	signal current_state : state_type;
	signal next_state : state_type;
	constant wait_time : time := 1000 ms;
	constant wait_count : integer := wait_time / system_clock_period;
	signal wait_counter : integer;
	signal led_output : std_ulogic_vector(7 downto 0);
	
begin

	
	
	next_state_logic: process(push_button, rst)
	begin
		if (rst = '1') then
			current_state <= switch_display;
		else 
			next_state <= switch_display;
		end if;
	end process next_state_logic;
	


	state_logic: process(clk, rst)
	begin
		if (wait_counter = 0 and current_state <= switch_display) then
			wait_counter <= wait_count;
		else
			wait_counter <= wait_counter - 1;
		end if;
	end process state_logic;

	output_logic: process(current_state)
	begin
		if (current_state = switch_display) then
			led <= "0000" & switches;
		else
			led <= led_output;
		end if;
	end process output_logic;

end architecture;

