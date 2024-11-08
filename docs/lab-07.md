# Lab 7: Verifying Your Custom Component Using System Console and /dev/mem

## Overview
This lab involved setting up an embedded logic analyzer to look at the program developed in lab 04 and verify the outputs are working. 

Devmem command 
	./devmem 
		0xff200000	hps_led_control
			0x0000	
			0x0001	
		0xff200004	base_period
			
		0xff200008 	led_reg
			0x007F	7-bits corresponding to led states

## Demonstration
	


### Pattern 00
![Single bit scrolling right screenshot](assets/Kirkland_Lab05_Pattern00.png)
### Pattern 01
![Two bits scrolling left](assets/Kirkland_Lab05_Pattern01.png)
### Pattern 02
![7-bit up counter](assets/Kirkland_Lab05_Pattern02.png)
### Pattern 03
![7-bit down counter](assets/Kirkland_Lab05_Pattern03.png)
### Pattern 04
![Fibbonaci sequence counter](assets/Kirkland_Lab05_Pattern04.png)

