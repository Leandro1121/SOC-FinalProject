#include <neorv32.h>
#include <stdint.h>

void trng_get_block128(uint8_t out[16]) {

  // clear old data
  neorv32_trng_fifo_clear();

  for (int i = 0; i < 16; i++) {

    // wait for data
    while (neorv32_trng_data_avail() == 0);

    // read one random byte
    out[i] = (uint8_t)neorv32_trng_data_get();
  }
}