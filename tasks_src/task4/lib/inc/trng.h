#ifndef TRNG_H
#define TRNG_H

#include <stdint.h>

void trng_get_block128(uint8_t out[16]);

#endif