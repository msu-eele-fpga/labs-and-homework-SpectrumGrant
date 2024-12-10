# Lab 10: Device Trees

## Overview

This lab involved modifying a device tree file to setup a heartbeat LED on the DE10 Nano board.

## Demo

cd /sys/class/leds/green\:heartbeat/
echo cpu > trigger


## Questions


### What is the purpose of a device tree?

A device tree describes the hardware that is accessable to the operating system. This describes the hardwares properties as a data structure that can be loaded during the boot sequence.