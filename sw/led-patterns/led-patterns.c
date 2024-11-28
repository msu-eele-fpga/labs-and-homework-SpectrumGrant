#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <sys/mman.h> // for mmap
#include <fcntl.h> // for file open flags
#include <unistd.h> // for getting the page size
#include <time.h>
#include <signal.h>

#define HPS_LED_CONTROL 0xff200000
#define BASE_PERIOD 0xff200004
#define LED_REG 0xff200008

static volatile bool interrupt_triggered = 0;

void help(); 
int file_loop(bool flg_verbose, char *file_name);
void interrupt_handler();
int pattern_loop(bool flg_verbose, int pattern_start, int argc, char **argv);
int write_pattern(bool flg_verbose, int pattern, int sleep_time);
int write_address(int address, int value);

int main(int argc, char **argv) {
	bool flg_verbose = false;
	bool flg_file = false;
	bool flg_pattern = false;
	char *file_name = NULL;
	int c;

	// If no arguments were given print help and exit
	if (argc == 1) {
		help();
		return 1;
	}
	int currentArg = 0;
	int pattern_start = 0;
	//int pattern[];
	// Handle arguments
	while ((c = getopt(argc, argv, "f:hp::v")) != -1) {
		currentArg++;
		switch (c) {
			case 'h':
				help();
				return 1;
			case 'v':
				flg_verbose = true;
				break;
			case 'f':
				flg_file = true;
				if (strcmp(optarg, "p") != 0)
					file_name = optarg;
				else {
					fprintf(stderr, "ERROR: Both file and pattern specified.\n");
					return 1;
				}
				break;
			case 'p':
				flg_pattern = true;
				pattern_start = ++currentArg;
				if ((argc - currentArg) % 2 != 0) {
					fprintf(stderr, "ERROR: Each pattern value needs a time value.");
				}
				break;
			case '?':
				fprintf(stderr, "optopt %d\n", optopt);
				break;
		}
	}
	signal(SIGINT, interrupt_handler);

	if ((flg_pattern == true) && (flg_file == true)) {
		fprintf(stderr, "ERROR: Both file and pattern specified.\n");
		return 1;
	} else if (flg_file == true) {
		return file_loop(flg_verbose, file_name);
	} else if (flg_pattern == true) {
		return pattern_loop(flg_verbose, pattern_start, argc, argv);
	} else {
		help();
		return 1;
	}
	
	return 0;
}

void help() {
	fprintf(stderr, "led-patterns [-hv][-f FILEPATH][-p PATTERN00 DURATION00 PATTERN01 DURATION01...]\n");
}


int file_loop(bool flg_verbose, char *file_name) {
	FILE* ptr_file = fopen(file_name, "r");

	if (ptr_file == NULL) {
		fprintf(stderr, "ERROR: Failed to open file.\n");
		return 1;
	}
	int sleep_time =0, pattern=0;
	int c;
	while ((c = fscanf(ptr_file, "0x%x %d\n", &pattern, &sleep_time)) == 2) {
		write_pattern(flg_verbose, pattern, sleep_time);
	}
	fclose(ptr_file);
	write_address(HPS_LED_CONTROL, 0);

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
	write_address(HPS_LED_CONTROL, 0);
}

/**
 * pattern_loop(bool flg_verbose, int pattern_start, int argc, char **argv) - Function 
 * for looping through input pattern.
 * 
 * @flg_verbose: Verbose flag determining if pattern write information is printed.
 * @pattern_start: The starting point in the arguments where the pattern is listed.
 * @argc: Total number of arguments.
 * @argv: Input arguments to program call.
 * 
 * Loops through input pattern calling write_address based on the arguments.
 * 
 * Return: 0 if completed successfully, 1 if error occurred.
 * 
 * Return will never be reached if working successfully, interrupt triggered through ctrl-c
 */
int pattern_loop(bool flg_verbose, int pattern_start, int argc, char **argv) {
	int i = pattern_start;
	while (interrupt_triggered == 0) {
		write_address(HPS_LED_CONTROL, 1);
		int pattern, sleep_time;
		sscanf(argv[i], "0x%x", &pattern);
		sscanf(argv[i+1], "%d", &sleep_time);
		if (write_pattern(flg_verbose, pattern, sleep_time) != 0) {
			return 1;
		}
		i+= 2;
		if (i >= argc) {
			i = pattern_start;
		}
	}
	return 0;
}

/**
 * write_pattern(bool flg_verbose, int pattern, int sleep_time) - Handles 
 * write call followed by sleep and verbose output.
 * 
 * @flg_verbose: Verbose flag determining if pattern write information is printed.
 * @pattern: The led pattern to be written to memory.
 * @sleep_time: The time to wait before completing.
 * 
 * write_pattern checks verbose flag, and if it is set outputs the pattern and wait 
 * time. Then sets the software control flag and writes the pattern to the LED_REG 
 * through the write_address function. Finally write_pattern sleeps for the 
 * specified time.
 * 
 * Return: 0 if completed successfully, 1 if error occurred.
 */
int write_pattern(bool flg_verbose, int pattern, int sleep_time) {
	if (flg_verbose) {
		printf("LED pattern = %8b Display time = %d ms", pattern, sleep_time);

	}
	if (write_address(HPS_LED_CONTROL, 1) != 0) {
		return 1;
	}
	if (write_address(LED_REG, pattern) != 0) {
		return 1;
	}
	usleep(sleep_time*1000);
	return 0;
}

/**
 * write_address(int address, int value) - Write a value to a given address.
 * @address: The address to be written.
 * @value: The value written to the address.
 * 
 * write_address opens and writes to an address in /dev/mem/ 
 * 
 * Return: 0 if completed successfully, 1 if error occurred.
 */
int write_address(int address, int value) {
	const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);
	const uint32_t ADDRESS = (uint32_t) address;

	int fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (fd == -1) {
		fprintf(stderr, "ERROR: failed to open /dev/mem.\n");
		return 1;
	}

	uint32_t page_aligned_addr = ADDRESS & ~(PAGE_SIZE -1);
	uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
	if (page_virtual_addr == MAP_FAILED) {
		fprintf(stderr, "ERROR: failed to map memory.\n");
		close(fd);
		return 1;
	}
	uint32_t offset_in_page = ADDRESS & (PAGE_SIZE - 1);
	volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t *);

	*target_virtual_addr = ((uint32_t) value);
	close(fd);
	return 0;
}