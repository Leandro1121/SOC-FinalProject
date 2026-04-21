#ifndef AES_CFS_H
#define AES_CFS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void aes128_encrypt_cfs(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]);
void aes128_decrypt_cfs(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]);

#ifdef __cplusplus
}
#endif

#endif