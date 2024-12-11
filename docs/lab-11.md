# Lab 11: Platform Device Driver

## Overview

This lab involved creating drivers for the led-patterns component allowing it to be run and implemented numerous ways. This also involved making attributes for the registers to be modified from the system level.

## Questions


### What is the purpose of the platform bus?

The platform bus allows hardware that is not discoverable to be connected to the OS through bespoke drivers.

### Why is the device driver's compatible property important?

Compatible parameter gives the kernel a key to match to the device tree to pair which driver goes with which device. 

### What is the probe function's purpose?

When the compatible parameter is found, the probe function is called. This then typically sets up the necessary parameters for the device such as memory allocation or initialization of registers.

### How does your driver know what memory addresses are associated with your device?

The base address and width are supplied in the device tree file alongside the compatible tag. 

### What are the two ways we can write to our device's registers? In other words, what subsystems do we use to write to our registers?

Either through opening the /dev/led-patterns miscellaneous device, or through the registers being made available as attributes.

### What is the purpose of our struct led_patterns-dev state container?

The state container defines what every led-patterns component has access to. It defines what parameters such as registers are associated with the device.