#ifndef _FREERTOS_NEORV32_HOOKS_H
#define _FREERTOS_NEORV32_HOOKS_H


#include "project_constants.h"

/* Prototypes for the standard FreeRTOS callback/hook functions implemented
 * within this file. See https://www.freertos.org/a00016.html */
void vApplicationMallocFailedHook(void);
void vApplicationIdleHook(void);
void vApplicationStackOverflowHook(TaskHandle_t pxTask, char *pcTaskName);
void vApplicationTickHook(void);

#endif 