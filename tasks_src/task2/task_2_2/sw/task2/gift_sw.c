#include <stdint.h>
#include "gift_sw.h"

#define GIFT128_ROUNDS 40

static const uint8_t GIFT_S[16] = {
	0x1, 0xA, 0x4, 0xC, 0x6, 0xF, 0x3, 0x9,
	0x2, 0xD, 0xB, 0x7, 0x5, 0x0, 0x8, 0xE
};

static const uint8_t GIFT_S_INV[16] = {
	0xD, 0x0, 0x8, 0x6, 0x2, 0xC, 0x4, 0xB,
	0xE, 0x7, 0x1, 0xA, 0x3, 0x9, 0xF, 0x5
};

static const uint8_t GIFT_P[128] = {
	  0, 33, 66, 99, 96,  1, 34, 67, 64, 97,  2, 35, 32, 65, 98,  3,
	  4, 37, 70,103,100,  5, 38, 71, 68,101,  6, 39, 36, 69,102,  7,
	  8, 41, 74,107,104,  9, 42, 75, 72,105, 10, 43, 40, 73,106, 11,
	 12, 45, 78,111,108, 13, 46, 79, 76,109, 14, 47, 44, 77,110, 15,
	 16, 49, 82,115,112, 17, 50, 83, 80,113, 18, 51, 48, 81,114, 19,
	 20, 53, 86,119,116, 21, 54, 87, 84,117, 22, 55, 52, 85,118, 23,
	 24, 57, 90,123,120, 25, 58, 91, 88,121, 26, 59, 56, 89,122, 27,
	 28, 61, 94,127,124, 29, 62, 95, 92,125, 30, 63, 60, 93,126, 31
};

static const uint8_t GIFT_P_INV[128] = {
	  0,  5, 10, 15, 16, 21, 26, 31, 32, 37, 42, 47, 48, 53, 58, 63,
	 64, 69, 74, 79, 80, 85, 90, 95, 96,101,106,111,112,117,122,127,
	 12,  1,  6, 11, 28, 17, 22, 27, 44, 33, 38, 43, 60, 49, 54, 59,
	 76, 65, 70, 75, 92, 81, 86, 91,108, 97,102,107,124,113,118,123,
	  8, 13,  2,  7, 24, 29, 18, 23, 40, 45, 34, 39, 56, 61, 50, 55,
	 72, 77, 66, 71, 88, 93, 82, 87,104,109, 98,103,120,125,114,119,
	  4,  9, 14,  3, 20, 25, 30, 19, 36, 41, 46, 35, 52, 57, 62, 51,
	 68, 73, 78, 67, 84, 89, 94, 83,100,105,110, 99,116,121,126,115
};

static const uint8_t GIFT_RC[62] = {
	0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3E, 0x3D, 0x3B, 0x37, 0x2F,
	0x1E, 0x3C, 0x39, 0x33, 0x27, 0x0E, 0x1D, 0x3A, 0x35, 0x2B,
	0x16, 0x2C, 0x18, 0x30, 0x21, 0x02, 0x05, 0x0B, 0x17, 0x2E,
	0x1C, 0x38, 0x31, 0x23, 0x06, 0x0D, 0x1B, 0x36, 0x2D, 0x1A,
	0x34, 0x29, 0x12, 0x24, 0x08, 0x11, 0x22, 0x04, 0x09, 0x13,
	0x26, 0x0C, 0x19, 0x32, 0x25, 0x0A, 0x15, 0x2A, 0x14, 0x28,
	0x10, 0x20
};

static void bytes_to_nibbles(const uint8_t in[16], uint8_t nibbles[32]) {
	for (int i = 0; i < 16; i++) {
		nibbles[31 - (2 * i)] = (uint8_t)((in[i] >> 4) & 0x0F);
		nibbles[30 - (2 * i)] = (uint8_t)(in[i] & 0x0F);
	}
}

static void nibbles_to_bytes(const uint8_t nibbles[32], uint8_t out[16]) {
	for (int i = 0; i < 16; i++) {
		out[i] = (uint8_t)(((nibbles[31 - (2 * i)] & 0x0F) << 4) |
		                   (nibbles[30 - (2 * i)] & 0x0F));
	}
}

static void update_key_state(uint8_t key[32]) {
	uint8_t temp[32];

	for (int i = 0; i < 32; i++) {
		temp[i] = key[(i + 8) % 32];
	}

	for (int i = 0; i < 24; i++) {
		key[i] = temp[i];
	}

	key[24] = temp[27];
	key[25] = temp[24];
	key[26] = temp[25];
	key[27] = temp[26];

	key[28] = (uint8_t)(((temp[28] & 0x0C) >> 2) | ((temp[29] & 0x03) << 2));
	key[29] = (uint8_t)(((temp[29] & 0x0C) >> 2) | ((temp[30] & 0x03) << 2));
	key[30] = (uint8_t)(((temp[30] & 0x0C) >> 2) | ((temp[31] & 0x03) << 2));
	key[31] = (uint8_t)(((temp[31] & 0x0C) >> 2) | ((temp[28] & 0x03) << 2));
}

static void add_round_key_and_constants(uint8_t state[32], const uint8_t key[32], int round) {
	uint8_t bits[128];
	uint8_t key_bits[128];

	for (int i = 0; i < 32; i++) {
		for (int j = 0; j < 4; j++) {
			bits[(4 * i) + j] = (uint8_t)((state[i] >> j) & 0x01);
			key_bits[(4 * i) + j] = (uint8_t)((key[i] >> j) & 0x01);
		}
	}

	for (int i = 0; i < 32; i++) {
		bits[(4 * i) + 1] ^= key_bits[i];
		bits[(4 * i) + 2] ^= key_bits[i + 64];
	}

	bits[3] ^= (uint8_t)( GIFT_RC[round]       & 0x01);
	bits[7] ^= (uint8_t)((GIFT_RC[round] >> 1) & 0x01);
	bits[11] ^= (uint8_t)((GIFT_RC[round] >> 2) & 0x01);
	bits[15] ^= (uint8_t)((GIFT_RC[round] >> 3) & 0x01);
	bits[19] ^= (uint8_t)((GIFT_RC[round] >> 4) & 0x01);
	bits[23] ^= (uint8_t)((GIFT_RC[round] >> 5) & 0x01);
	bits[127] ^= 0x01;

	for (int i = 0; i < 32; i++) {
		uint8_t nibble = 0;
		for (int j = 0; j < 4; j++) {
			nibble |= (uint8_t)(bits[(4 * i) + j] << j);
		}
		state[i] = nibble;
	}
}

static void perm_bits(uint8_t state[32]) {
	uint8_t bits[128];
	uint8_t perm[128];

	for (int i = 0; i < 32; i++) {
		for (int j = 0; j < 4; j++) {
			bits[(4 * i) + j] = (uint8_t)((state[i] >> j) & 0x01);
		}
	}

	for (int i = 0; i < 128; i++) {
		perm[GIFT_P[i]] = bits[i];
	}

	for (int i = 0; i < 32; i++) {
		uint8_t nibble = 0;
		for (int j = 0; j < 4; j++) {
			nibble |= (uint8_t)(perm[(4 * i) + j] << j);
		}
		state[i] = nibble;
	}
}

static void inv_perm_bits(uint8_t state[32]) {
	uint8_t bits[128];
	uint8_t perm[128];

	for (int i = 0; i < 32; i++) {
		for (int j = 0; j < 4; j++) {
			bits[(4 * i) + j] = (uint8_t)((state[i] >> j) & 0x01);
		}
	}

	for (int i = 0; i < 128; i++) {
		perm[GIFT_P_INV[i]] = bits[i];
	}

	for (int i = 0; i < 32; i++) {
		uint8_t nibble = 0;
		for (int j = 0; j < 4; j++) {
			nibble |= (uint8_t)(perm[(4 * i) + j] << j);
		}
		state[i] = nibble;
	}
}

void gift128_encrypt_sw(const uint8_t key_in[16], const uint8_t in[16], uint8_t out[16]) {
	uint8_t state[32];
	uint8_t key[32];

	bytes_to_nibbles(in, state);
	bytes_to_nibbles(key_in, key);

	for (int round = 0; round < GIFT128_ROUNDS; round++) {
		for (int i = 0; i < 32; i++) {
			state[i] = GIFT_S[state[i]];
		}

		perm_bits(state);
		add_round_key_and_constants(state, key, round);
		update_key_state(key);
	}

	nibbles_to_bytes(state, out);
}

void gift128_decrypt_sw(const uint8_t key_in[16], const uint8_t in[16], uint8_t out[16]) {
	uint8_t state[32];
	uint8_t key[32];
	uint8_t round_key_state[GIFT128_ROUNDS][32];

	bytes_to_nibbles(in, state);
	bytes_to_nibbles(key_in, key);

	for (int round = 0; round < GIFT128_ROUNDS; round++) {
		for (int i = 0; i < 32; i++) {
			round_key_state[round][i] = key[i];
		}
		update_key_state(key);
	}

	for (int round = GIFT128_ROUNDS - 1; round >= 0; round--) {
		add_round_key_and_constants(state, round_key_state[round], round);
		inv_perm_bits(state);
		for (int i = 0; i < 32; i++) {
			state[i] = GIFT_S_INV[state[i]];
		}
	}

	nibbles_to_bytes(state, out);
}
