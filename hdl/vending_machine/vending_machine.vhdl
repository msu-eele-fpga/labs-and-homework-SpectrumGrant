----------------------------------------------------------------------------
-- Description:  
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 11, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity vending_machine is
	port (
		clk		: in	std_ulogic;
		rst		: in	std_ulogic;
		nickel	: in	std_ulogic;
		dime		: in	std_ulogic;
		dispense	: out	std_ulogic;
		amount	: out	natural range 0 to 15
    );
end entity vending_machine;

architecture vending_machine_arch of vending_machine is

type State_Type is (Cents0, Cents5, Cents10, Cents15);

Signal	current_state, next_state : State_Type;

begin
	state_memory : process(clk, rst)
	begin
		if (rst = '0') then
			current_state <= Cents0;
		elsif (rising_edge(clk)) then
			current_state <= next_state;
		end if;
	end process state_memory;
	
	next_state_logic : process(current_state, nickel, dime)
	begin
		case (current_state) is
			when Cents0 => 
				if (dime = '1') then
					next_state <= Cents10;
				elsif (nickel = '1') then
					next_state <= Cents5;
				else
					next_state <= Cents0;
				end if;
			when others =>
				null;
		end case;
	end process next_state_logic;
	
	output_logic : process(current_state)
	begin
		case (current_state) is 
			when Cents0 =>
				dispense <= '0';
				amount <= 0;
			when Cents5 =>
				dispense <= '0';
				amount <= 5;
			when Cents10 =>
				dispense <= '0';
				amount <= 10;
			when Cents15 =>
				dispense <= '1';
				amount <= 15;
			when others =>
				null;
		end case;
	end process output_logic;
	
end architecture vending_machine_arch;