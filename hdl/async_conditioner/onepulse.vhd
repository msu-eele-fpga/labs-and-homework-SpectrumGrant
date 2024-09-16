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

entity onepulse is
	port (clk		: in	std_logic;
			rst		: in	std_logic;
			input		: in	std_logic;
			pulse		: out	std_logic);
end entity;

architecture onepulse_arch of onepulse is 
	type State_Type is (standby, output_pulse, lift);
	signal current_state : State_Type;

begin
	State_Logic: process(clk, rst)
	begin
		if (rst = '1') then
			current_state <= standby; 
		elsif (rising_edge(clk)) then
			case (current_state) is
				when standby => if (input = '1') then current_state <= output_pulse; end if;
				when output_pulse => 
					if (input = '0') then
						current_state <= standby;
					else
						current_state <= lift;
					end if;
				when lift => if (input = '0') then current_state <= standby; end if;
			end case;
		end if;
	end process;
	
	pulse_Logic: process(current_state)
	begin
			case (current_state) is
				when output_pulse => pulse <= '1';
				when others => pulse <= '0';
			end case;
	end process;
	
end architecture;