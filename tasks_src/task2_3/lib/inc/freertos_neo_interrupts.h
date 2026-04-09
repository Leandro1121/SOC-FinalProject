#ifndef _FREERTOS_NEORV32_INTERRUPTS_H
#define _FREERTOS_NEORV32_INTERRUPTS_H

#include "project_constants.h"
#include "freertos_neo_tasks.h"

void setGPIOInterrupts(int pin);
void initButtonSystem(void);

#endif 