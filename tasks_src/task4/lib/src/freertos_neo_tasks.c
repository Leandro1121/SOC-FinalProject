#include "freertos_neo_tasks.h"

// Define them once here
QueueHandle_t xButtonQueue    = NULL;
TaskHandle_t  xButtonTaskHandle = NULL;

void prvButtonTask(void *pvParameters) {
    (void)pvParameters;
    ButtonEvent_t event;
    for (;;) {
        if (xQueueReceive(xButtonQueue, &event, portMAX_DELAY)) {

            vTaskDelay(pdMS_TO_TICKS(DEBOUNCE_DELAY));

            // If True, button is pressed
            event.edge = (neorv32_gpio_pin_get(event.pin) != 0);

            // *********** Button Press or release actions here  ********* //
            // Button Actions here 
            neorv32_uart_printf(UART_HW_HANDLE,
                "Pin %u: %s\n",
                event.pin,
                event.edge ? "rising edge (pressed)" : "falling edge (released)"
            );

            // Send to Pong
            uint32_t buttons = neorv32_gpio_port_get();
            uint32_t pong_cmd = 0;

            if (buttons & 0x01u) pong_cmd |= P1_DN; 
            if (buttons & 0x02u) pong_cmd |= P1_UP;
            if (buttons & 0x04u) pong_cmd |= P2_DN;
            if (buttons & 0x08u) pong_cmd |= P2_UP;
            if (buttons & 0x10u) pong_cmd |= START;

            uint32_t started = (pong_cmd & START) ? 1u : 0u;

            neorv32_cpu_store_unsigned_word(PONG_IP_BASE + 0x0u, pong_cmd);

            // Send through SPI?

            // *********************************************************** // 
            neorv32_gpio_irq_setup(
                event.pin, 
                event.edge ? GPIO_TRIG_EDGE_FALLING : GPIO_TRIG_EDGE_RISING
            );
            neorv32_gpio_irq_enable(1U << event.pin);      
        }
        
    }
}