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
	signal base_period: std_ulogic_vector(31 downto 0) := "00000000000000000000000000010000";
	signal led_reg : std_ulogic_vector(31 downto 0) := "00000000000000000000000000000000";

	signal bool_conversion : boolean;
		
	component led_patterns is
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
	end component;
	
begin
	
	boolean_conversion : process(hps_led_control)
	begin
		if hps_led_control(0) then
			bool_conversion <= true;
		else
			bool_conversion <= false;
		end if;
	end process;
	
	CMP_LED_PATTERNS : led_patterns
	generic map (
		system_clock_period => 20 ns
	)
	port map (
		clk => clk,
		rst => rst,
		push_button => push_button,
		switches => switches,
		hps_led_control => bool_conversion,
		base_period => unsigned(base_period(7 downto 0)),
		led_reg => led_reg(7 downto 0),
		led => led
	);

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

	avalon_register_write : process(clk, rst)
	begin
		if (rst = '1') then
			hps_led_control <= "00000000000000000000000000000000";
			base_period <= "00000000000000000000000000010000";
			led_reg <= "00000000000000000000000000000000";
		elsif (rising_edge(clk) and avs_write = '1') then
			case avs_address is 
				when "00" => hps_led_control <= avs_writedata(31 downto 0);
				when "01" => base_period <= avs_writedata(31 downto 0);
				when "10" => led_reg <= avs_writedata(31 downto 0);
				when others => null;
			end case;
		end if;
	end process;

end architecture led_patterns_avalon_arch;