# Usage

```
usage: led-patterns [-h] [-v] [-f F | -p P [P ...]]

Runs through a sequential series of led outputs paired with durations. Accepts both file and command line patern inputs.

options:
  -h		    show this help message and exit
  -v            print additional information with file and pattern commands.
  -f F          read file and display patterns listed.
  -p P [P ...]  cycle continuously through pattern duration pairs. Any even number of inputs seperated by spaces.
  ```

# Installation

The program can be compiled through the following command, and once compiled moved onto the dev board it will be run on.  
`arm-linux-gnueabihf-gcc -o led-patterns -Wall -static led-patterns.c`  
 This requires the FPGA be programmed with the corresponding LED patterns program, located at `..\..\quartus\LED_Patterns\soc_system.rbf`.
