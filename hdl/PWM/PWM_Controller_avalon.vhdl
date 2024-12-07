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

entity PWM_controller_avalon is 
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
		GPIO				: out	std_logic
	);
end entity PWM_controller_avalon;

architecture PWM_controller_avalon_arch of PWM_controller_avalon is
	signal clk_period : time := 20 ns;
	signal duty_cycle_width : integer := 22;
	signal period_width : integer := 13;
	signal period: std_ulogic_vector(31 downto 0) 		:= "00000000000000000000000010000000";
	signal duty_cycle: std_ulogic_vector(31 downto 0) 	:= "00000000000100000000000000000000"; -- 50%
		
	component PWM_Controller is
		generic (
			CLK_PERIOD		: time := clk_period;
			W_DUTY_CYCLE	: integer := duty_cycle_width; -- 22.21;
			W_PERIOD			: integer := period_width  -- 13.7
		);
		port (
			clk			: in	std_logic;
			rst			: in	std_logic;
			period		: in	unsigned(W_PERIOD - 1 downto 0);
			duty_cycle	: in	unsigned(W_DUTY_CYCLE - 1 DOWNTO 0);
			output		: out	std_logic := '0'
		);
	end component PWM_Controller;
	
begin
	
	CMP_PWM : PWM_Controller
	generic map (
		CLK_PERIOD => clk_period,
		W_DUTY_CYCLE => duty_cycle_width,
		W_PERIOD => period_width
	)
	port map (
		clk => clk,
		rst => rst,
		period => unsigned(period(period_width - 1 downto 0)),
		duty_cycle => unsigned(duty_cycle(duty_cycle_width - 1 DOWNTO 0)),
		output => GPIO
	);

	avalon_register_read : process(clk)
	begin
		if (rising_edge(clk) and avs_read = '1') then
			case avs_address is 
				when "00" => avs_readdata <= std_logic_vector(period);
				when "01" => avs_readdata <= std_logic_vector(duty_cycle);
				when others => avs_readdata <= (others => '0');
			end case;
		end if;
	end process avalon_register_read;

	avalon_register_write : process(clk, rst)
	begin
		if (rst = '1') then
			period <= "00000000000000000000000010000000";
			duty_cycle <= "00000000000100000000000000000000";
		elsif (rising_edge(clk) and avs_write = '1') then
			case avs_address is 
				when "00" => period <= std_ulogic_vector(avs_writedata(31 downto 0));
				when "01" => duty_cycle <= std_ulogic_vector(avs_writedata(31 downto 0));
				when others => null;
			end case;
		end if;
	end process;

end architecture PWM_controller_avalon_arch;