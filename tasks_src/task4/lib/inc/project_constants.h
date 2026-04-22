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

#define PONG_IP_BASE 0x40000000u

// Buttons to Bit mapping 
#define P1_DN (1u << 0)
#define P1_UP (1u << 1)
#define P2_DN (1u << 2)
#define P2_UP (1u << 3)
#define START (1u << 4)

#endif