#include <neorv32.h>
#include <stdint.h>
#include "crypto_utils.h"

void print_byte_hex(uint8_t b) {
	const char hex[] = "0123456789abcdef";
	neorv32_uart0_putc(hex[(b >> 4) & 0xF]);
	neorv32_uart0_putc(hex[b & 0xF]);
}

void print_block_hex(const char *label, const uint8_t *block) {
	neorv32_uart0_printf("%s", label);

	for (int i = 0; i < 16; i++) {
		print_byte_hex(block[i]);
	}

	neorv32_uart0_printf("\n");
}