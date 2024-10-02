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

	type state_type is (standby, switch_display, pattern_00, pattern_01, pattern_02, pattern_03, pattern_04);
	signal current_state : state_type; -- tracks current state
	signal next_state : state_type; -- tracks which state to move into
	signal switch_state : state_type; -- tracks last valid switch setting
	signal state_pulse : std_ulogic := '0';

	signal wait_counter : integer; -- current count for the switch value display
	signal switch_hold_value : std_ulogic_vector(3 downto 0);
	signal led_output : std_ulogic_vector(7 downto 0) := "00000000";

	signal timer : integer := 0;
	signal timer_done : std_ulogic := '1';
	
--	signal pattern_counter : integer;
	-- convert system_clock_period to frequency, then can multiply base_period by frequency and treat answer as having the same number of decimal places.
	
begin

	state_memory: process(clk, rst)
	begin
		if (rst = '1') then
			current_state <= standby;
		elsif (rising_edge(clk)) then
			if (current_state = next_state) then
				state_pulse <= '0';
			else
				state_pulse <= '1';
			end if;
			current_state <= next_state;
		end if;
	end process state_memory;
	
	next_state_logic: process(push_button, clk, rst)
	begin
		if (rst = '1') then
			switch_state <= pattern_00;
			next_state <= standby;
		elsif (rising_edge(push_button)) then
			next_state <= switch_display;
			wait_counter <= system_clock_frequency - 1;
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
			if (rising_edge(clk) and current_state = switch_display and wait_counter > 0) then
				wait_counter <= wait_counter - 1;
			elsif (current_state = switch_display and wait_counter = 0) then
				next_state <= switch_state;
			end if;
		end if;
	end process next_state_logic;
	


	state_logic: process(clk, state_pulse, rst)
	begin
		if (rst = '1') then
			timer <= 0;
		elsif (rising_edge(state_pulse)) then
			case (next_state) is 
				when pattern_00 => 
					timer <= to_integer(shift_right((system_clock_frequency * base_period), 5)) - 1;
				when others => timer <= 0;
			end case;
		elsif (rising_edge(clk) and timer = 0) then
			case (current_state) is
				when pattern_00 => 
					timer <= to_integer(shift_right((system_clock_frequency * base_period), 5)) - 1;
					timer_done <= '1';
				when pattern_01 => 
					timer <= to_integer(shift_right((system_clock_frequency * base_period), 6)) - 1;
					timer_done <= '1';
				when pattern_02 => 
					timer <= to_integer(shift_right((system_clock_frequency * base_period), 3)) - 1;
					timer_done <= '1';
				when pattern_03 => 
					timer <= to_integer(shift_right((system_clock_frequency * base_period), 7)) - 1;
					timer_done <= '1';
				when others => timer <= 0; timer_done <= '0';
			end case;
		elsif (rising_edge(clk)) then
			timer <= timer - 1;
			timer_done <= '0';
		end if;
	end process state_logic;

	led_update: process(state_pulse, timer_done)
	begin
		-- led_output initialization
		if (rising_edge(state_pulse)) then
			case (next_state) is
				when pattern_00 => led_output <= "00000001";
				when pattern_01 => led_output <= "11000000";
				when others => led_output <= "00000000";
			end case;
		elsif (rising_edge(timer_done)) then
			case (current_state) is
				when pattern_00 => led_output <= std_ulogic_vector(rotate_left(unsigned(led_output), 1));
				when pattern_01 => led_output <= std_ulogic_vector(rotate_right(unsigned(led_output), 2));
				when others => null;
			end case;
		end if;
--		if (led_counter > 0) then
--			led_counter = led_counter - 1;
--		else 
--			case (current_state) is
--				when pattern_00 => led_counter = system_clock_frequency
--				when others => led_output = "00000000";
--			end case;
--		end if
	end process led_update;
	
	output_logic: process(clk, rst)
	begin
		if (hps_led_control = false and rising_edge(clk)) then
			case (current_state) is
				when switch_display => led <= "0000" & switch_hold_value;
				when pattern_00 => led <= led_output;
				when pattern_01 => led <= led_output;
				when pattern_02 => led <= led_output;
				when pattern_03 => led <= led_output;
				when others => led <= "10101010";
			end case;
		elsif (hps_led_control = true) then
			led <= led_reg;
		end if;
	end process output_logic;

end architecture;

