#include "freertos_neo_interrupts.h"

void setGPIOInterrupts(int pin)
{
    // Check GPIO is available
    if (neorv32_gpio_available() == 0) {
        neorv32_uart_printf(UART_HW_HANDLE, "ERROR! GPIO not available!\n");
        return;
    }

    // Set pin as input — clear its bit in the direction register
    uint32_t dir = neorv32_gpio_dir_get();
    dir &= ~(1U << pin); // clear bit = input
    neorv32_gpio_dir_set(dir);

    neorv32_uart_printf(UART_HW_HANDLE, "GPIO dir reg after pin %d setup: 0x%08x\n", pin, neorv32_gpio_dir_get());
    neorv32_uart_printf(UART_HW_HANDLE, "GPIO port state: 0x%08x\n", neorv32_gpio_port_get());

    // Rising Edge for the board
    neorv32_gpio_irq_setup(pin, GPIO_TRIG_EDGE_RISING);

    neorv32_gpio_irq_enable(1U << pin);
}

void initButtonSystem(void)
{
    // Unmask GPIO FIRQ in machine interrupt enable register
    neorv32_cpu_csr_set(CSR_MIE, 1 << GPIO_FIRQ_ENABLE);

    // Create queue before starting scheduler — holds up to 10 events
    xButtonQueue = xQueueCreate(10, sizeof(ButtonEvent_t));
    if (xButtonQueue == NULL) {
        neorv32_uart_printf(UART_HW_HANDLE, "ERROR! Failed to create button queue!\n");
        return;
    }

    xTaskCreate(prvButtonTask, "BTN", 256, NULL, tskIDLE_PRIORITY + 2, &xButtonTaskHandle);
}

/******************************************************************************
 * Handle NEORV32-/application-specific interrupts.
 ******************************************************************************/
void freertos_risc_v_application_interrupt_handler(void) {

    uint32_t mcause = neorv32_cpu_csr_read(CSR_MCAUSE); // add this
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;       // add this

    switch(mcause)
    {
        case GPTMR_TRAP_CODE:
        {
            neorv32_gptmr_irq_ack(neorv32_gptmr_irq_get()); // clear GPTMR timer-match interrupt
            neorv32_uart_printf(UART_HW_HANDLE, "GPTMR IRQ Tick\n");
        }
        break;
        
        case GPIO_TRAP_CODE:
        {
            uint32_t pending = neorv32_gpio_irq_get();
            neorv32_gpio_irq_clr(pending);

            uint32_t pin;
            for (pin = 0; pin <= 4; pin++) {
                if (pending & (1 << pin)) {
                    // Disable GPIO interrupt to debounce button
                    neorv32_gpio_irq_disable(1 << pin);
                    // Create and Send button press event
                    ButtonEvent_t event = {
                        .pin  = pin
                    };
                    xQueueSendFromISR(xButtonQueue, &event, &xHigherPriorityTaskWoken);
                }
            }
            
            portYIELD_FROM_ISR(xHigherPriorityTaskWoken);

        }
        break; 

        case SPI_TRAP_CODE:
        {
            neorv32_uart_printf(UART_HW_HANDLE, "SPI IRQ\n");
            /* Add SPI Interrupt here*/
        }
        break;

        default:
        {
            neorv32_uart_printf(UART_HW_HANDLE, "\n<NEORV32-IRQ> Unexpected IRQ! cause=0x%x </NEORV32-IRQ>\n", mcause); // debug output
        }
        break; 
    }
}
