# Usage

# Installation

The program can be compiled through the following command, and once compiled moved onto the dev board it will be run on.  
`arm-linux-gnueabihf-gcc -o led-patterns -Wall -static led-patterns.c`  
 This requires the FPGA be programmed with the corresponding LED patterns program, located at `..\..\quartus\LED_Patterns\soc_system.rbf`.
