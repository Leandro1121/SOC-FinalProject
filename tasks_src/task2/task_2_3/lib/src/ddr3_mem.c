#include "ddr3_mem.h"

void ddr3_test()
{
    // Checking if DDR3 is connected and initialized 
    if(!neorv32_gpio_pin_get(DDR_CALIBRATION_PIN))
        neorv32_uart_printf(UART_HW_HANDLE, "DDR3 Ram is disconnected\n");

    volatile uint32_t *ddr = (volatile uint32_t *) DDR_BASE;

    //Write a series of numbers into memory 
    neorv32_uart_printf(UART_HW_HANDLE, "Writing to DDR...\n");
    for (int i = 0; i < 1024; i++) {
        ddr[i] = 0xDEADBEEF;
    }

    // Read back and verify
    neorv32_uart_printf(UART_HW_HANDLE, "Reading from DDR...\n");
    int errors = 0;
    for (int i = 0; i < 1024; i++) {
        if (ddr[i] != 0xDEADBEEF) {
            neorv32_uart_printf(UART_HW_HANDLE, 
                "Error at offset %d: got 0x%x\n", i, ddr[i]);
            errors++;
        }
    }

    if (errors == 0)
        neorv32_uart_printf(UART_HW_HANDLE, "DDR test PASSED!\n");
    else
        neorv32_uart_printf(UART_HW_HANDLE, "DDR test FAILED! %d errors\n", errors);
}
