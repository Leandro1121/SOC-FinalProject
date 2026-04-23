#ifndef CRYPTO_UTILS_H
#define CRYPTO_UTILS_H

#include <stdint.h>

void print_block_hex(const char *label, const uint8_t *block);
void print_byte_hex(uint8_t b);
int eq16(const uint8_t a[16], const uint8_t b[16]);


#endif