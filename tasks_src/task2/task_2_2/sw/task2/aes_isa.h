#ifndef AES_ISA_H
#define AES_ISA_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

uint32_t aes32esmi_bs0(uint32_t rs1, uint32_t rs2);
uint32_t aes32esmi_bs1(uint32_t rs1, uint32_t rs2);
uint32_t aes32esmi_bs2(uint32_t rs1, uint32_t rs2);
uint32_t aes32esmi_bs3(uint32_t rs1, uint32_t rs2);

uint32_t aes32esi_bs0(uint32_t rs1, uint32_t rs2);
uint32_t aes32esi_bs1(uint32_t rs1, uint32_t rs2);
uint32_t aes32esi_bs2(uint32_t rs1, uint32_t rs2);
uint32_t aes32esi_bs3(uint32_t rs1, uint32_t rs2);

void aes128_encrypt_isa(const uint8_t key[16], const uint8_t pt[16], uint8_t ct[16]);

#ifdef __cplusplus
}
#endif

#endif