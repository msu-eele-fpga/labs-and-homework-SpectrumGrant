----------------------------------------------------------------------------
-- Description:  LED pattern device which implements the state machine and the asynchronous conditioning conditions on the push button input.
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  October 13, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity led_patterns_avalon is 
	port (
		clk				: in	std_ulogic;
		rst				: in	std_ulogic;
		
		-- avalon memory-mapped slave interface
		avs_read			: in	std_logic;
		avs_write		: in	std_logic;
		avs_address		: in	std_logic_vector(1 downto 0);
		avs_readdata	: out	std_logic_vector(31 downto 0);
		avs_writedata	: in	std_logic_vector(31 downto 0);
		
		-- external I/O; export to top-level
		push_button		: in	std_ulogic;
		switches			: in	std_ulogic_vector(3 downto 0);
		led				: out	std_ulogic_vector(7 downto 0)
	);
end entity led_patterns_avalon;

architecture led_patterns_avalon_arch of led_patterns_avalon is

	signal hps_led_control: std_ulogic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal base_period: std_ulogic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal led_reg : std_ulogic_vector(31 downto 0) := "00000000000000000000000000000000";

begin

	avalon_register_read : process(clk)
	begin
		if (rising_edge(clk) and avs_read = '1') then
			case avs_address is 
				when "00" => avs_readdata <= hps_led_control;
				when "01" => avs_readdata <= base_period;
				when "10" => avs_readdata <= led_reg;
				when others => avs_readdata <= (others => '0');
			end case;
		end if;
	end process avalon_register_read;



end architecture;