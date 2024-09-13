----------------------------------------------------------------------------
-- Description:  One pulse test bench
----------------------------------------------------------------------------
-- Author:       Grant Kirkland
-- Company:      Montana State University
-- Create Date:  September 13, 2024
-- Revision:     1.0
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity onepulse_tb is
end entity onepulse_tb;


architecture onepulse_tb_arch of onepulse_tb is

signal clk_tb	: std_ulogic := '0';
signal rst_tb	: std_ulogic := '0';

begin



end architecture onepulse_tb_arch;