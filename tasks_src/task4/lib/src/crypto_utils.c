#include <neorv32.h>
#include <stdint.h>
#include "crypto_utils.h"

void print_byte_hex(uint8_t b) {
	const char hex[] = "0123456789abcdef";
	
	neorv32_uart0_putc(hex[(b >> 4) & 0xF]);
	neorv32_uart0_putc(hex[b & 0xF]);
	neorv32_uart0_printf("===========================\n");
}

void print_block_hex(const char *label, const uint8_t *block) {
	neorv32_uart0_printf("%s", label);

	for (int i = 0; i < 16; i++) {
		print_byte_hex(block[i]);
	}

	neorv32_uart0_printf("\n");
}

int eq16(const uint8_t a[16], const uint8_t b[16]) {
	for (int i = 0; i < 16; i++) {
		if (a[i] != b[i]) {
			return 0;
		}
	}
	return 1;
}