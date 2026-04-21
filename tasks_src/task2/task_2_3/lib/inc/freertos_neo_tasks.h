#ifndef _FREERTOS_NEORV32_TASKS_H
#define _FREERTOS_NEORV32_TASKS_H


#include "project_constants.h"

typedef struct {
    uint32_t pin;
    uint32_t edge; // 1 = rising (press), 0 = falling (release)
} ButtonEvent_t;

extern QueueHandle_t xButtonQueue;
extern TaskHandle_t  xButtonTaskHandle;

void prvButtonTask(void *pvParameters);

#endif