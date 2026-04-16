#ifndef CRYPTO_API_H
#define CRYPTO_API_H

#include <stdint.h>

int aes128_encrypt_sw(const uint8_t *key, const uint8_t *in, uint8_t *out);
int aes128_decrypt_sw(const uint8_t *key, const uint8_t *in, uint8_t *out);

int gift128_encrypt_sw(const uint8_t *key, const uint8_t *in, uint8_t *out);
int gift128_decrypt_sw(const uint8_t *key, const uint8_t *in, uint8_t *out);

void print_block_hex(const char *label, const uint8_t *block);
int block_equal(const uint8_t *a, const uint8_t *b);

#endif