#ifndef _PROJECT_CONSTANTS_H
#define _PROJECT_CONSTANTS_H

/* FreeRTOS kernel */
#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>

/* NEORV32 HAL */
#include <neorv32.h>

/* Standard includes. */
#include <string.h>
#include <unistd.h>
#include <stdint.h>


/* Platform UART configuration */
#define UART_BAUD_RATE (19200)         // transmission speed
#define UART_HW_HANDLE (NEORV32_UART0) // use UART0 (primary UART)

/* DDR3 configuration */
#define DDR_BASE 0x88000000
#define DDR_SIZE (128 * 1024 * 1024)  // 128MB
#define DDR_CALIBRATION_PIN 7

#define DEBOUNCE_DELAY 50
#define WDT_TIMEOUT_S 5

#endif