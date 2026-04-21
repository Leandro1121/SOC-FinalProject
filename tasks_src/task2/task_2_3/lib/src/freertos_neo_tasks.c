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

            // Send to Pong? 
            // Send through SPI?

            // *********************************************************** // 
            neorv32_gpio_irq_setup(
                event.pin, 
                event.edge ? GPIO_TRIG_EDGE_FALLING : GPIO_TRIG_EDGE_RISING
            );
            neorv32_gpio_irq_enable(1 << event.pin);      
        }
        
    }
}