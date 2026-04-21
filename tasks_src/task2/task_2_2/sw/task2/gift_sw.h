#ifndef GIFT_SW_H
#define GIFT_SW_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void gift128_encrypt_sw(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]);
void gift128_decrypt_sw(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]);

#ifdef __cplusplus
}
#endif

#endif
