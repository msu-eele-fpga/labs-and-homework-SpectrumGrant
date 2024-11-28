#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <sys/mman.h> // for mmap
#include <fcntl.h> // for file open flags
#include <unistd.h> // for getting the page size
#include <time.h>

#define HPS_LED_CONTROL 0xff200000
#define BASE_PERIOD 0xff200004
#define LED_REG 0xff200008

void help(); 
int fileLoop(bool verboseFlag, char *fileVal);
int writePattern(bool verboseFlag, int pattern, int sleepTime);
int write_address(int address, int value);

int main(int argc, char **argv) {
	bool verboseFlag = false;
	bool fileFlag = false;
	bool patternFlag = false;
	char *fileVal = NULL;
	int c;

	// If no arguments were given print help and exit
	if (argc == 1) {
		help();
		return 1;
	}

	// Handle arguments
	while ((c = getopt(argc, argv, "f:hp::v")) != -1) {
		switch (c) {
			case 'h':
				help();
				return 1;
			case 'v':
				verboseFlag = true;
				break;
			case 'f':
				fileFlag = true;
				if (strcmp(optarg, "p") != 0)
					fileVal = optarg;
				else {
					fprintf(stderr, "ERROR: Both file and pattern specified.\n");
					return 1;
				}
				break;
			case 'p':
				patternFlag = true;
				break;
			case '?':
				fprintf(stderr, "optopt %d\n", optopt);
				break;
		}
	}

	if ((patternFlag == true) && (fileFlag == true)) {
		fprintf(stderr, "ERROR: Both file and pattern specified.\n");
		return 1;
	} else if (fileFlag == true) {
		fileLoop(verboseFlag, fileVal);
	} else if (patternFlag == true) {

	} else {
		help();
		return 1;
	}
	
	return 0;
}

void help() {
	fprintf(stderr, "led-patterns [-hv][-f FILEPATH][-p PATTERN00 DURATION00 PATTERN01 DURATION01...]\n");
}

int fileLoop(bool verboseFlag, char *fileVal) {
	FILE* filePointer = fopen(fileVal, "r");

	if (filePointer == NULL) {
		fprintf(stderr, "ERROR: Failed to open file.\n");
		return 1;
	}
//	char pattern[5];
	int sleepTime =0, pattern=0;
	int c;
	while ((c = fscanf(filePointer, "0x%x %d\n", &pattern, &sleepTime)) == 2) {
		writePattern(verboseFlag, pattern, sleepTime);
	}
	fclose(filePointer);
	write_address(HPS_LED_CONTROL, 0);

	return 0;
}

int writePattern(bool verboseFlag, int pattern, int sleepTime) {
	write_address(HPS_LED_CONTROL, 1);
	if (verboseFlag) {
		printf("LED pattern = %8b Display time = %d ms", pattern, sleepTime);
	}
	write_address(LED_REG, pattern);
	usleep(sleepTime*1000);
	return 0;
}

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