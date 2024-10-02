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
	constant system_clock_frequency : integer := 1 sec / system_clock_period; -- 50,000,000 for 20ns

	type state_type is (switch_display, pattern_00, pattern_01, pattern_02, pattern_03, pattern_04);
	signal current_state : state_type; -- tracks current state
	signal next_state : state_type; -- tracks which state to move into
	signal switch_state : state_type; -- tracks last valid switch setting

	signal wait_counter : integer; -- current count for the switch value display
	signal switch_hold_value : std_ulogic_vector(3 downto 0);
	signal timer : integer := 0;
	signal led_output : std_ulogic_vector(7 downto 0);
	
--	signal pattern_counter : integer;
	-- convert system_clock_period to frequency, then can multiply base_period by frequency and treat answer as having the same number of decimal places.
	
begin

	state_memory: process(clk, rst)
	begin
		if (rst = '1') then
			current_state <= switch_display;
		elsif (rising_edge(clk)) then
			current_state <= next_state;
		end if;
	end process state_memory;
	
	next_state_logic: process(push_button, clk, rst)
	begin
		if (rst = '1') then
			switch_state <= pattern_00;
		elsif (rising_edge(push_button)) then
			next_state <= switch_display;
			wait_counter <= system_clock_frequency;
			switch_hold_value <= switches;
			case (switches) is
					when "0000" => switch_state <= pattern_00; 
					when "0001" => switch_state <= pattern_01; 
					when "0010" => switch_state <= pattern_02; 
					when "0011" => switch_state <= pattern_03; 
					when "0100" => switch_state <= pattern_04; 
					when others => switch_state <= switch_state;
			end case;
		else
			if (current_state = switch_display and wait_counter > 0) then
				wait_counter <= wait_counter - 1;
			elsif (current_state = switch_display) then
				next_state <= switch_state;
			end if;
		end if;
	end process next_state_logic;
	


	state_logic: process(clk)
	begin
		if (timer = 0) then
			timer <= 1 sec / system_clock_period; -- base
		end if;
	end process state_logic;

	output_logic: process(clk, rst)
	begin
		if (hps_led_control = false) then
			case (current_state) is
				when switch_display => led <= "0000" & switch_hold_value;
--				when pattern_00 =>
--					case (pattern_counter) is 
--						when 0 => led <= "10000000"; 
--						when 1 => led <= "01000000"; 
--						when 2 => led <= "00100000"; 
--						when 3 => led <= "00010000"; 
--						when 4 => led <= "00001000"; 
--						when 5 => led <= "00000100"; 
--						when 6 => led <= "00000010"; 
--						when 7 => led <= "00000001"; 
--					end case;
--				when pattern_01 => --rotate right
				when others => led <= "10101010";
			end case;
		else
			led <= led_reg;
		end if;
	end process output_logic;

end architecture;

