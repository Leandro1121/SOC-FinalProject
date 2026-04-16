#include <neorv32.h>
#include <stdint.h>
#include "gift_cfs.h"

#define CFS_CTRL_START   (1u << 0)
#define CFS_CTRL_DONE    (1u << 1)
#define CFS_CTRL_MODE    (1u << 2) // 1 = GIFT, 0 = AES
#define CFS_CTRL_DEC     (1u << 4)

static void pack_words(const uint8_t in[16], uint32_t w[4]) {
	w[3] = ((uint32_t)in[0] << 24) | ((uint32_t)in[1] << 16) |
	       ((uint32_t)in[2] << 8)  | ((uint32_t)in[3]);
	w[2] = ((uint32_t)in[4] << 24) | ((uint32_t)in[5] << 16) |
	       ((uint32_t)in[6] << 8)  | ((uint32_t)in[7]);
	w[1] = ((uint32_t)in[8] << 24) | ((uint32_t)in[9] << 16) |
	       ((uint32_t)in[10] << 8) | ((uint32_t)in[11]);
	w[0] = ((uint32_t)in[12] << 24) | ((uint32_t)in[13] << 16) |
	       ((uint32_t)in[14] << 8)  | ((uint32_t)in[15]);
}

static void unpack_words(const uint32_t w[4], uint8_t out[16]) {
	out[0]  = (uint8_t)((w[3] >> 24) & 0xFF);
	out[1]  = (uint8_t)((w[3] >> 16) & 0xFF);
	out[2]  = (uint8_t)((w[3] >> 8) & 0xFF);
	out[3]  = (uint8_t)(w[3] & 0xFF);
	out[4]  = (uint8_t)((w[2] >> 24) & 0xFF);
	out[5]  = (uint8_t)((w[2] >> 16) & 0xFF);
	out[6]  = (uint8_t)((w[2] >> 8) & 0xFF);
	out[7]  = (uint8_t)(w[2] & 0xFF);
	out[8]  = (uint8_t)((w[1] >> 24) & 0xFF);
	out[9]  = (uint8_t)((w[1] >> 16) & 0xFF);
	out[10] = (uint8_t)((w[1] >> 8) & 0xFF);
	out[11] = (uint8_t)(w[1] & 0xFF);
	out[12] = (uint8_t)((w[0] >> 24) & 0xFF);
	out[13] = (uint8_t)((w[0] >> 16) & 0xFF);
	out[14] = (uint8_t)((w[0] >> 8) & 0xFF);
	out[15] = (uint8_t)(w[0] & 0xFF);
}

static void gift128_crypt_cfs(const uint8_t key[16], const uint8_t in[16], uint8_t out[16], uint32_t ctrl_extra) {
	uint32_t key_w[4];
	uint32_t data_w[4];

	pack_words(key, key_w);
	pack_words(in, data_w);

	for (int i = 0; i < 4; i++) {
		NEORV32_CFS->REG[i] = key_w[i];
		NEORV32_CFS->REG[4 + i] = data_w[i];
	}

	NEORV32_CFS->REG[8] = CFS_CTRL_START | CFS_CTRL_MODE | ctrl_extra;

	while ((NEORV32_CFS->REG[8] & CFS_CTRL_DONE) == 0u) {
	}

	for (int i = 0; i < 4; i++) {
		data_w[i] = NEORV32_CFS->REG[9 + i];
	}

	unpack_words(data_w, out);
}

void gift128_encrypt_cfs(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]) {
	gift128_crypt_cfs(key, in, out, 0u);
}

void gift128_decrypt_cfs(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]) {
	gift128_crypt_cfs(key, in, out, CFS_CTRL_DEC);
}
