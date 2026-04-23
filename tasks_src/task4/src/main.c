
#include "project_constants.h"
#include "freertos_neo_hooks.h"
#include "freertos_neo_tasks.h"
#include "freertos_neo_interrupts.h"
#include "ddr3_mem.h"

extern void freertos_risc_v_trap_handler(void); // FreeRTOS core
extern void freertos_risc_v_application_interrupt_handler(void);

/******************************************************************************
 * Main function (should never return).
 ******************************************************************************/
int main( void ) 
{
    /******************************************************************************
    * FreeRTOS + NEORV32 initialization
    ******************************************************************************/

    // capture all exceptions and give debug info via UART
    // this is not required, but keeps us safe
    neorv32_rte_setup();

    // install the freeRTOS kernel trap handler
    neorv32_cpu_csr_write(CSR_MTVEC, (uint32_t)&freertos_risc_v_trap_handler);
    
    // setting axi gpios as outputs
    neorv32_cpu_store_unsigned_word(PONG_IP_BASE + 0x4u, 0x00000000u);

    // Setup UART0 at default baud rate, no interrupts
    neorv32_uart0_setup(UART_BAUD_RATE, 0);

    neorv32_uart0_puts("\nCRYPTO\n");

    // TRNG Setup 
    if (neorv32_trng_available()) {
		neorv32_trng_enable();
		neorv32_aux_delay_ms(neorv32_sysinfo_get_clk(), 100);
		neorv32_trng_fifo_clear();
		neorv32_uart0_puts("TRNG OK\n");
        trng_get_block128(aes_k);
	} else {
		neorv32_uart0_puts("TRNG NO\n");
	}

    // check if UART0 is implemented at all
    if(neorv32_uart0_available() == 0)
        return -1; 
    
    // ******************* Watch Dog Timmer Check and Setup ************************ // 
    
    if(neorv32_wdt_available() == 0)
    {
        neorv32_uart_printf(UART_HW_HANDLE, "ERROR! WDT not available!\n");
        return -1;
    }
    else  
    {
        neorv32_uart0_puts("Cause of last processor reset: ");
        switch(neorv32_wdt_get_cause()) 
        {
            case WDT_RCAUSE_EXT:
                neorv32_uart0_puts("External Reset\n");
                break;
            case WDT_RCAUSE_OCD:
                neorv32_uart0_puts("On-chip debugger reset\n");
                break;
            case WDT_RCAUSE_TMO:
                neorv32_uart0_puts("Watchdog timeout\n");
                break;
            case  WDT_RCAUSE_ACC:
                neorv32_uart0_puts("Watchdog illegal access\n");
                break;
            default:
                neorv32_uart0_puts("Unknown\n");
        }

         // compute WDT timeout value; the WDT counter increments at f_wdt = f_main / 4096
        uint32_t timeout = WDT_TIMEOUT_S * (neorv32_sysinfo_get_clk() / 4096);
        if (timeout & 0xFF000000U) { // check if timeout value fits into 24-bit
            neorv32_uart0_puts("Timeout value does not fit into 24-bit!\n");
            return -1;
        }

        neorv32_wdt_setup(timeout, 0);
    }
   
    // ******************** Watch Dog Timmer Check and Setup ************************ //  

    neorv32_aux_delay_ms(neorv32_sysinfo_get_clk(), 3000);

    neorv32_aux_print_logo();
    neorv32_uart0_puts("\n-- Pong Game Initializing --\n");

    // clear GPIO output (set all bits to 0)
    neorv32_gpio_port_set(0);

    // Setting Input Button Interrupt and Queue System 
    initButtonSystem();
    setGPIOInterrupts(0);
    setGPIOInterrupts(1);
    setGPIOInterrupts(2);
    setGPIOInterrupts(3);
    setGPIOInterrupts(4);
    // Init SPI System? 

    // CLINT available?
    if (neorv32_clint_available() == 0) {
        neorv32_uart_printf(UART_HW_HANDLE, "ERROR! CLINT not available!\n");
    }

    // general purpose timer available?
    if (neorv32_gptmr_available() == 0) {
        neorv32_uart_printf(UART_HW_HANDLE, "WARNING! GPTMR timer not available!\n");
    }

    // check clock frequency configuration
    uint32_t neorv32_clk_hz = (uint32_t)NEORV32_SYSINFO->CLK;
    if (neorv32_clk_hz != (uint32_t)configCPU_CLOCK_HZ) {
        neorv32_uart_printf(UART_HW_HANDLE,
                            "WARNING! Incorrect 'configCPU_CLOCK_HZ' configuration!\n"
                            "FreeRTOS configCPU_CLOCK_HZ: %u Hz\n"
                            "NEORV32 clock speed:         %u Hz\n\n",
                            (uint32_t)configCPU_CLOCK_HZ, neorv32_clk_hz);
    }

    // // ----------------------------------------------------------
    // // Configure general-purpose timer (GPTMR) tick
    // // ----------------------------------------------------------

    if (neorv32_gptmr_available() != 0) { // GPTMR implemented at all?

        // configure timer slice 0: continuous mode with clock divider = 64,
        // fire interrupt every 4 seconds
        neorv32_gptmr_setup(CLK_PRSC_64);
        neorv32_gptmr_configure(0, 0, (configCPU_CLOCK_HZ / 64) * 4, 1);

        // enable GPTMR interrupt
        neorv32_cpu_csr_set(CSR_MIE, 1 << GPTMR_FIRQ_ENABLE);
        neorv32_gptmr_enable_single(0);
    }

    // Testing DDR3 Memory Starting at Address 0x8800_0000
    ddr3_test();

    // say hello
    neorv32_uart_printf(UART_HW_HANDLE, "\n<<< NEORV32 running FreeRTOS %s >>>\n\n", tskKERNEL_VERSION_NUMBER);

    vTaskStartScheduler();

    while(1); 

    // we should never reach this
    neorv32_uart_printf(UART_HW_HANDLE, "WARNING! Pong Game returned!\n");
    return -1;
}




/******************************************************************************
 * Handle NEORV32-/application-specific exceptions.
 ******************************************************************************/
void freertos_risc_v_application_exception_handler(void) {

  // mcause identifies the cause of the exception
  uint32_t mcause = neorv32_cpu_csr_read(CSR_MCAUSE);

  // mepc identifies the address of the exception
  uint32_t mepc = neorv32_cpu_csr_read(CSR_MEPC);

  // debug output
  neorv32_uart_printf(UART_HW_HANDLE, "\n<NEORV32-EXC> mcause = 0x%x @ mepc = 0x%x </NEORV32-EXC>\n", mcause,mepc); // debug output
}

