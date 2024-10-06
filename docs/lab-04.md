# Lab 4: LED Patterns

## Project Overview

The LED patterns project involved creating a vhdl program that was capable of switching between multiple output states. This involved implementing a number of different states that displayed differing LED patterns, as well as a state that displayed the current switch settings upon a button push, before the system would advance to the input LED state. Additionally, this system had the ability to set different base update multipliers, using a fixed point value, that would affect the update speed of the LED patterns. This system also had an override to allow for alternative input LED control.

### Functional Requirements

1. LED control can be overriden with HPS_LED_Control signal.

2. LED 7 acts as a heartbeat LED blinking at the base rate in seconds.

3. There are 5 LED states with differing update frequencies and patterns.

	1. This is a pattern involving a single lit LED shifting right at 1/2 * base rate seconds.
	2. This is a pattern involving two adjacent bits shifting left, at a rate of 1/4 * base rate seconds.
	3. This is a 7-bit up counter, updating every 2 * base rate seconds.
	4. This is a 7-bit down counter, updating every 1/8 * base rate seconds.
	5. This is a user defined pattern, updating every 1 * base rate seconds, outputting the last 7 bits in the Fibonacci sequence, starting from 1.

4. When the push button is pressed, the system displays switch code, and if it is valid switches to new state after 1 second. Otherwise stays in current state. The system only changes states on a push button input.

5. The external push-button signal is conditioned to produce a synchronous single pulse, with a period of 1 clock cycle.

## System Architecture

![System Block Diagram](assets/Lab04_BlockDiagram.pdf)

## Deliverables

n/a
