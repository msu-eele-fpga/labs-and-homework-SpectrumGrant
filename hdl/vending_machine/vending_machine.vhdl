----------------------------------------------------------------------------
-- Description:  Timed Counter component, when enabled counts for set time before outputting high for one clock cycle. If disabled outputs low.
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 9, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity vending_machine is
	port (
		clk		: in	std_ulogic,
		rst		: in	std_ulogic,
		nickel	: in	std_ulogic,
		dime		: in	std_ulogic,
		dispense	: out	std_ulogic,
		amount	: out	natural range 0 to 15
    );
end entity vending_machine