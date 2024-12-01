# Lab 8: Creating LED Patterns with a C Program Using /dev/mem in Linux

## Overview

This lab involved creating a c program to be run through a terminal that could read in files or take arguments that described a pattern to display on the LEDs.

## Memory Addresses
 HPS_LED_CONTROL 0xff200000  
 BASE_PERIOD 0xff200004
 LED_REG 0xff200008

These addresses come from the combination of the lightweight bridge base address (0xff200000) + the component base address (0x00000000) + the register offsets of 4 bytes each as each register is 32 bits.

## Deliverables

[README for led-patterns](../sw/led-patterns/README.md)
