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


entity timed_counter is
	generic (
		clk_period : time;
		count_time : time
	);
	port (
		clk	: in	std_ulogic;
		enable: in	boolean;
		done	: out	boolean
	);
	
end entity timed_counter;

architecture timed_counter_arch of timed_counter is

signal CNT : integer range 0 to 255;
constant COUNTER_LIMIT : integer := count_time / clk_period; 

begin
	Counter : process(clk)
	begin
		if (enable = false) then
			done <= false;
			CNT <= 0;
		elsif (enable = true and rising_edge(clk)) then
			CNT <= CNT + 1;
			if (CNT = COUNTER_LIMIT) then
				done <= true;
				CNT <= 0;
			else
				done <= false;
			end if;
		end if;
	end process;
end architecture;