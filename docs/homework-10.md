# Homework 10: RGB LED Controller VHDL

## Overview

This assignment involved creating a pulse width modulator with variable period and duty cycle, and then expands that to output three different signals which will drive 3 different LEDs. One red, one green, and one blue to allow a variety of different colors to be created.

## LED Resistor Calculations

Red

$$  R_1 > \frac{(3.3-2.1)}{0.02} = 60\ \Omega $$


$$ 252\frac{\text{lm}}{\text{W}} * 2.1 \text{ V} * \frac{(3.3 - 2.1)}{R_1} \frac{\text{V}}{\Omega} = \frac{635}{R_1} \text{lm}$$


Green
$$  R_2 > \frac{(3.3-3.1)}{0.02} = 10\ \Omega $$


$$ 537\frac{\text{lm}}{\text{W}} * 3.1 \text{ V} * \frac{(3.3 - 3.1)}{R_2} \frac{\text{V}}{\Omega} = \frac{332.94}{R_2}\text{lm}$$


Blue
$$  R_3 > \frac{(3.3-3.1)}{0.02} = 10\ \Omega $$


$$ 79\frac{\text{lm}}{\text{W}} * 3.1 \text{ V} * \frac{(3.3 - 3.1)}{R_3} \frac{\text{V}}{\Omega} = \frac{48.98}{R_3}\text{lm}$$

## Deliverables

### <span style="color:red">  LED Photo Red </span>
![A screenshot of a awesome red led](assets/Kirkland_Homework10_Red.jpg)

### <span style="color:green">  LED Photo Green </span>
![A screenshot of a awesome green led](assets/Kirkland_Homework10_Green.jpg)

### <span style="color:blue"> LED Photo Blue </span> 
![A screenshot of a awesome blue led](assets/Kirkland_Homework10_Blue.jpg)

### <span style="color:#ffaaaa"> LED Photo Rosewater </span>
![A screenshot of a awesome rosewater led](assets/Kirkland_Homework10_Rosewater.jpg)

### <span style="color:#E49B0F"> LED Photo Gamboge </span>
![A screenshot of a awesome gamboge led](assets/Kirkland_Homework10_Gamboge.jpg)

