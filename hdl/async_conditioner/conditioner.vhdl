----------------------------------------------------------------------------
-- Description:  Takes arbitrary length input, synchronizes, debounces, and outputs one pulse
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  October 10, 2023
-- Revision:     1.0
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Conditioner is
	port (Clock		: in	std_logic;
			Btn		: in	std_logic;
			Reset		: in	std_logic;
			Pulse		: out	std_logic);
end entity;

architecture Conditioner_arch of Conditioner is 

	component Synchronizer
	port (Clock		: in	std_logic;
			D			: in	std_logic;
			Q2			: out	std_logic);
	end component;
	
	component Debouncer
	port (Clock		: in	std_logic;
			btn		: in	std_logic;
			reset		: in	std_logic;
			dbn		: out	std_logic);
	end component;

	component OnePulse
	port (Clock		: in	std_logic;
			btn		: in	std_logic;
			reset		: in	std_logic;
			output	: out	std_logic);
	end component;

	signal synched_Output: std_logic;
	signal debounced_Output: std_logic;
begin

	CMP_SYNC: Synchronizer
	port map(Clock => Clock,
				D => Btn,
				Q2 => synched_Output);

	CMP_DEB: Debouncer
	port map(Clock => Clock,
				btn => synched_Output,
				reset => Reset,
				dbn => debounced_Output);
				
	CMP_OP: OnePulse
	port map(Clock => Clock,
				btn	=> debounced_Output,
				reset	=> Reset,
				output=> Pulse);

end architecture;