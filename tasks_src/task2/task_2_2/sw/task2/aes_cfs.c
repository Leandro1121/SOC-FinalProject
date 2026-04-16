#include <neorv32.h>
#include <stdint.h>
#include "aes_cfs.h"

#define CFS_CTRL_START   (1u << 0)
#define CFS_CTRL_MODE    (1u << 2) // 0=AES
#define CFS_CTRL_DEC     (1u << 4)
#define CFS_CTRL_DONE    (1u << 1)

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

static void unpack_words(uint32_t w[4], uint8_t out[16]) {
	out[0]  = (w[3] >> 24) & 0xFF;
	out[1]  = (w[3] >> 16) & 0xFF;
	out[2]  = (w[3] >> 8)  & 0xFF;
	out[3]  = (w[3])       & 0xFF;

	out[4]  = (w[2] >> 24) & 0xFF;
	out[5]  = (w[2] >> 16) & 0xFF;
	out[6]  = (w[2] >> 8)  & 0xFF;
	out[7]  = (w[2])       & 0xFF;

	out[8]  = (w[1] >> 24) & 0xFF;
	out[9]  = (w[1] >> 16) & 0xFF;
	out[10] = (w[1] >> 8)  & 0xFF;
	out[11] = (w[1])       & 0xFF;

	out[12] = (w[0] >> 24) & 0xFF;
	out[13] = (w[0] >> 16) & 0xFF;
	out[14] = (w[0] >> 8)  & 0xFF;
	out[15] = (w[0])       & 0xFF;
}

void aes128_encrypt_cfs(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]) {

	uint32_t key_w[4];
	uint32_t data_w[4];

	pack_words(key, key_w);
	pack_words(in, data_w);

	// write key
	for (int i = 0; i < 4; i++)
		NEORV32_CFS->REG[i] = key_w[i];

	// write block
	for (int i = 0; i < 4; i++)
		NEORV32_CFS->REG[4 + i] = data_w[i];

	// start AES encrypt
	NEORV32_CFS->REG[8] = CFS_CTRL_START;

	// wait done
	while (!(NEORV32_CFS->REG[8] & CFS_CTRL_DONE));

	// read result
	for (int i = 0; i < 4; i++)
		data_w[i] = NEORV32_CFS->REG[9 + i];

	unpack_words(data_w, out);
}

void aes128_decrypt_cfs(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]) {

	uint32_t key_w[4];
	uint32_t data_w[4];

	pack_words(key, key_w);
	pack_words(in, data_w);

	// write key
	for (int i = 0; i < 4; i++)
		NEORV32_CFS->REG[i] = key_w[i];

	// write block
	for (int i = 0; i < 4; i++)
		NEORV32_CFS->REG[4 + i] = data_w[i];

	// START + DECRYPT BIT
	NEORV32_CFS->REG[8] = CFS_CTRL_START | CFS_CTRL_DEC;

	// wait done
	while (!(NEORV32_CFS->REG[8] & CFS_CTRL_DONE));

	// read result
	for (int i = 0; i < 4; i++)
		data_w[i] = NEORV32_CFS->REG[9 + i];

	unpack_words(data_w, out);
}