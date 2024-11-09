# Lab 7: Verifying Your Custom Component Using System Console and /dev/mem

## Overview

This lab involved setting up the previously developed code as a binary file to boot the FPGA from. Additionally, setting up the system console, after programming the FPGA. And using compiled c code to access /dev/mem in linux to control the system.

### System Console

```
	master_write 0x00 0xAA 0xBB 0xCC
		00 Index from register 0
		AA hps_led_control 
			00 hardware 
			01 software
		BB	base period register. 8-bit fixed point value with 4 bits representing decimal.
		CC	LED Register. Output values to leds in software control mode
```

### Devmem command 
```	
	./devmem 
		0xff200000	hps_led_control
			0x0000	hps_led_control is false and disabled. System runs from LED state machine.
			0x0001	hps_led_control is true and enabled. System runs from led register.
		0xff200004	base_period
			0x00FF	8-bit fixed point value, with 4 bits representing the decimal.
		0xff200008 	led_reg
			0x007F	7-bits, with each bit corresponding to led states.
```
## Demonstration

1. In System Console, put your system in software control mode and write a value to the LEDs.
   
   `master_write_32 0x00 0x01 0x10 0x3d`
2. In System Console, put your system in hardware control mode and set your base_period to 0.125 seconds.
   

	`master_write_32 0x00 0x00 0x01 0x00`
3. In Linux, using devmem, put your system in software control mode and write a value to the LEDs.
   
	`./devmem 0xff200000 0x0001`

	`./devmem 0xff200008 0x0055`

4. In Linux, using devmem, put your system in hardware control mode and set your base_period to 0.5625
seconds.

	`./devmem 0xff200000 0x0000`

	`./devmem 0xff200004 0x000A` 

