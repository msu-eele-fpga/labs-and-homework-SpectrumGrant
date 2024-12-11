#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

// TODO: update these offsets if your address are different
#define HPS_LED_CONTROL_OFFSET 0x0
#define BASE_PERIOD_OFFSET 0x4
#define LED_REG_OFFSET 0x08
int pattern_loop();
void interrupt_handler();

static volatile bool interrupt_triggered = 0;

int main () {
	FILE *file;
	size_t ret;	
	uint32_t val;

	file = fopen("/dev/led_patterns" , "rb+" );
	if (file == NULL) {
		printf("failed to open file\n");
		exit(1);
	}

	// Test reading the registers sequentially
	printf("\n************************************\n*");
	printf("* read initial register values\n");
	printf("************************************\n\n");

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("base period = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);

	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);
	printf("fseek ret = %u\n", ret);
	printf("errno =%s\n", strerror(errno));


	printf("\n************************************\n*");
	printf("* write values\n");
	printf("************************************\n\n");
	// Turn on software-control mode
	val = 0x01;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	// We need to "flush" so the OS finishes writing to the file before our code continues.
	fflush(file);

	// Write some values to the LEDs
	printf("writing patterns to LEDs....\n");
	val = 0x55;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(1);

	val = 0xaa;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(1);

	val = 0xff;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	usleep(0.5e6);

	val = 0x00;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(1);

	// Turn on hardware-control mode
	printf("back to hardware-control mode....\n");
	val = 0x00;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	val = 0x12;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(5);

	// Speed up the base period!
	val = 0x02;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);


	printf("\n************************************\n*");
	printf("* read new register values\n");
	printf("************************************\n\n");
	
	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("base period = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);

	printf("\n************************************\n");
	printf(  "**            Looping             **\n");
	printf(  "************************************\n\n");

	signal(SIGINT, interrupt_handler);
	pattern_loop(file);

	fclose(file);
	return 0;
}

/**
 * interrupt_handler() - Sets exit flag and returns control to hardware.
 * 
 * Triggered on an entry of control-c, setting exit loop boolean for 
 * pattern, and returning control of the LEDs to the hardware system.
 */
void interrupt_handler() {
	interrupt_triggered = 1;
}

int pattern_loop(FILE *file) {
	uint32_t val, prev, hold;
	size_t ret;	
	prev = 0x00;

	val = 0x01;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);
	printf("HPS_LED_control = 0x%x\n", val);

	val = 0x10;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);
	printf("base period = 0x%x\n", val);

	val = 0x01;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);
	printf("LED_reg = 0x%x\n", val);

	while (interrupt_triggered == 0) {
		hold = val;
		val = val + prev;
		prev = hold;

		ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
		ret = fwrite(&val, 4, 1, file);
		fflush(file);
		printf("LED_reg = 0x%x\n", val);
		sleep(1);

	}

	val = 0x00;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);

	return ret;
}
