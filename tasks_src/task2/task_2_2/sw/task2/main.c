#include <neorv32.h>
#include <stdint.h>

#include "aes_sw.h"
#include "aes_cfs.h"
#include "aes_isa.h"
#include "gift_sw.h"
#include "crypto_utils.h"
#include "trng.h"

#define NTEST 100

static inline uint64_t cyc(void) {
	return neorv32_cpu_get_cycle();
}

static int eq16(const uint8_t a[16], const uint8_t b[16]) {
	for (int i = 0; i < 16; i++) {
		if (a[i] != b[i]) {
			return 0;
		}
	}
	return 1;
}

int main(void) {
	const uint8_t aes_k[16] = {
		0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,
		0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
	};
	const uint8_t aes_p[16] = {
		0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,
		0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff
	};
	const uint8_t aes_e[16] = {
		0x69,0xc4,0xe0,0xd8,0x6a,0x7b,0x04,0x30,
		0xd8,0xcd,0xb7,0x80,0x70,0xb4,0xc5,0x5a
	};

	const uint8_t gift_k0[16] = {
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	};
	const uint8_t gift_p0[16] = {
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	};
	const uint8_t gift_e0[16] = {
		0xcd,0x0b,0xd7,0x38,0x38,0x8a,0xd3,0xf6,
		0x68,0xb1,0x5a,0x36,0xce,0xb6,0xff,0x92
	};

	const uint8_t gift_k1[16] = {
		0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,
		0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
	};
	const uint8_t gift_p1[16] = {
		0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,
		0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff
	};
	const uint8_t gift_e1[16] = {
		0x18,0x16,0x91,0xd5,0x26,0xa3,0xc6,0x78,
		0xdd,0x28,0xfb,0x9f,0x1c,0xe3,0x1f,0xdd
	};

	uint8_t aes_sw_ct[16], aes_hw_ct[16], aes_is_ct[16], aes_dec[16];
	uint8_t gift_sw_ct[16], gift_dec[16];
	uint8_t rk[16], rp[16], rct1[16], rct2[16], rct3[16];

	uint64_t t0, t1;
	uint32_t c_sw, c_hw, c_is;

	neorv32_rte_setup();
	neorv32_uart0_setup(19200, 0);

	neorv32_uart0_puts("\nCRYPTO\n");

	if (neorv32_trng_available()) {
		neorv32_trng_enable();
		neorv32_aux_delay_ms(neorv32_sysinfo_get_clk(), 100);
		neorv32_trng_fifo_clear();
		neorv32_uart0_puts("TRNG OK\n");
	} else {
		neorv32_uart0_puts("TRNG NO\n");
	}

	/* AES */
	neorv32_uart0_puts("\nAES\n");

	aes128_encrypt_sw(aes_k, aes_p, aes_sw_ct);
	aes128_encrypt_cfs(aes_k, aes_p, aes_hw_ct);
	aes128_encrypt_isa(aes_k, aes_p, aes_is_ct);
	aes128_decrypt_sw(aes_k, aes_sw_ct, aes_dec);

	print_block_hex("K ", aes_k);
	print_block_hex("P ", aes_p);
	print_block_hex("S ", aes_sw_ct);
	print_block_hex("H ", aes_hw_ct);
	print_block_hex("I ", aes_is_ct);
	print_block_hex("E ", aes_e);

	neorv32_uart0_puts(eq16(aes_sw_ct, aes_e)  ? "A-SW PASS\n" : "A-SW FAIL\n");
	neorv32_uart0_puts(eq16(aes_hw_ct, aes_e)  ? "A-HW PASS\n" : "A-HW FAIL\n");
	neorv32_uart0_puts(eq16(aes_is_ct, aes_e)  ? "A-IS PASS\n" : "A-IS FAIL\n");
	neorv32_uart0_puts(eq16(aes_sw_ct, aes_hw_ct) ? "A-SH PASS\n" : "A-SH FAIL\n");
	neorv32_uart0_puts(eq16(aes_sw_ct, aes_is_ct) ? "A-SI PASS\n" : "A-SI FAIL\n");
	neorv32_uart0_puts(eq16(aes_dec, aes_p)   ? "A-DC PASS\n" : "A-DC FAIL\n");

	t0 = cyc();
	for (int i = 0; i < NTEST; i++) {
		aes128_encrypt_sw(aes_k, aes_p, aes_sw_ct);
	}
	t1 = cyc();
	c_sw = (uint32_t)(t1 - t0);

	t0 = cyc();
	for (int i = 0; i < NTEST; i++) {
		aes128_encrypt_cfs(aes_k, aes_p, aes_hw_ct);
	}
	t1 = cyc();
	c_hw = (uint32_t)(t1 - t0);

	t0 = cyc();
	for (int i = 0; i < NTEST; i++) {
		aes128_encrypt_isa(aes_k, aes_p, aes_is_ct);
	}
	t1 = cyc();
	c_is = (uint32_t)(t1 - t0);

	neorv32_uart0_printf("A cyc sw/hw/is %u %u %u\n", c_sw, c_hw, c_is);
	if (c_hw) {
		neorv32_uart0_printf("A spd hw %u\n", c_sw / c_hw);
	}
	if (c_is) {
		neorv32_uart0_printf("A spd is %u\n", c_sw / c_is);
	}

	if (neorv32_trng_available()) {
		trng_get_block128(rk);
		trng_get_block128(rp);
		aes128_encrypt_sw(rk, rp, rct1);
		aes128_encrypt_cfs(rk, rp, rct2);
		aes128_encrypt_isa(rk, rp, rct3);
		neorv32_uart0_puts((eq16(rct1, rct2) && eq16(rct1, rct3)) ? "A-RND PASS\n" : "A-RND FAIL\n");
	}

	/* GIFT SW only */
	neorv32_uart0_puts("\nGFT\n");

	gift128_encrypt_sw(gift_k0, gift_p0, gift_sw_ct);
	gift128_decrypt_sw(gift_k0, gift_sw_ct, gift_dec);
	print_block_hex("S0 ", gift_sw_ct);
	print_block_hex("E0 ", gift_e0);
	neorv32_uart0_puts(eq16(gift_sw_ct, gift_e0) ? "G0 PASS\n" : "G0 FAIL\n");
	neorv32_uart0_puts(eq16(gift_dec, gift_p0)   ? "G0 DEC PASS\n" : "G0 DEC FAIL\n");

	gift128_encrypt_sw(gift_k1, gift_p1, gift_sw_ct);
	gift128_decrypt_sw(gift_k1, gift_sw_ct, gift_dec);
	print_block_hex("S1 ", gift_sw_ct);
	print_block_hex("E1 ", gift_e1);
	neorv32_uart0_puts(eq16(gift_sw_ct, gift_e1) ? "G1 PASS\n" : "G1 FAIL\n");
	neorv32_uart0_puts(eq16(gift_dec, gift_p1)   ? "G1 DEC PASS\n" : "G1 DEC FAIL\n");

	t0 = cyc();
	for (int i = 0; i < NTEST; i++) {
		gift128_encrypt_sw(gift_k1, gift_p1, gift_sw_ct);
	}
	t1 = cyc();
	neorv32_uart0_printf("G cyc sw %u\n", (uint32_t)(t1 - t0));

	if (neorv32_trng_available()) {
		trng_get_block128(rk);
		trng_get_block128(rp);
		gift128_encrypt_sw(rk, rp, rct1);
		gift128_decrypt_sw(rk, rct1, rct2);
		neorv32_uart0_puts(eq16(rct2, rp) ? "G-RND PASS\n" : "G-RND FAIL\n");
	}

	neorv32_uart0_puts("DONE\n");

	while (1) {
	}
	return 0;
}