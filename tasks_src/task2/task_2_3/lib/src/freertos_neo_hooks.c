#include "freertos_neo_hooks.h"

//#################################################################################################
// FreeRTOS Hooks
//#################################################################################################

/******************************************************************************
 * Hook for failing malloc.
 ******************************************************************************/
void vApplicationMallocFailedHook(void) {

	/* vApplicationMallocFailedHook() will only be called if
	configUSE_MALLOC_FAILED_HOOK is set to 1 in FreeRTOSConfig.h. It is a hook
	function that will get called if a call to pvPortMalloc() fails.
	pvPortMalloc() is called internally by the kernel whenever a task, queue,
	timer or semaphore is created. It is also called by various parts of the
	demo application. The size of the heap available to pvPortMalloc() is
	defined by configTOTAL_HEAP_SIZE in FreeRTOSConfig.h. The
	xPortGetFreeHeapSize() API function can be used to query the size of free
	heap space that remains (although it does not provide information on how
	the remaining heap might be fragmented).

	If heap_3.c is used, then configTOTAL_HEAP_SIZE has no effect and the heap
	size is instead defined by setting the linker variable __neorv32_heap_size.
	xPortGetFreeHeapSize() cannot be used with heap_3.c. */

	taskDISABLE_INTERRUPTS();

  neorv32_uart_puts(UART_HW_HANDLE,
                    "FreeRTOS_FAULT: vApplicationMallocFailedHook "
                    "(increase 'configTOTAL_HEAP_SIZE' in FreeRTOSConfig.h)\n");

	__asm volatile("ebreak"); // trigger context switch

	while(1);
}


/******************************************************************************
 * Hook for the idle process.
 ******************************************************************************/
void vApplicationIdleHook(void) {

	/* vApplicationIdleHook() will only be called if configUSE_IDLE_HOOK is set
	to 1 in FreeRTOSConfig.h. It will be called on each iteration of the idle
	task. It is essential that code added to this hook function never attempts
	to block in any way (for example, call xQueueReceive() with a block time
	specified, or call vTaskDelay()). If the application makes use of the
	vTaskDelete() API function (as this demo application does) then it is also
	important that vApplicationIdleHook() is permitted to return to its calling
	function, because it is the responsibility of the idle task to clean up
	memory allocated by the kernel to any task that has since been deleted. */

    // Reset Watch Dog Timer
    neorv32_wdt_feed(WDT_PASSWORD);

    neorv32_cpu_sleep(); // cpu wakes up on any interrupt request
}


/******************************************************************************
 * Hook for task stack overflow.
 ******************************************************************************/
void vApplicationStackOverflowHook(TaskHandle_t pxTask, char *pcTaskName) {

	(void)pcTaskName;
	(void)pxTask;

	/* Run time stack overflow checking is performed if
	configCHECK_FOR_STACK_OVERFLOW is defined to 1 or 2. This hook
	function is called if a stack overflow is detected. */

	taskDISABLE_INTERRUPTS();

  neorv32_uart_printf(UART_HW_HANDLE,
                      "FreeRTOS_FAULT: vApplicationStackOverflowHook "
                      "(increase 'configISR_STACK_SIZE_WORDS' in FreeRTOSConfig.h)\n");

	__asm volatile("ebreak"); // trigger context switch

	while(1);
}


/******************************************************************************
 * Hook for the application tick (unused).
 ******************************************************************************/
void vApplicationTickHook(void) {

  __asm volatile( "nop" ); // nothing to do here yet
}

/******************************************************************************
 * Assert terminator.
 ******************************************************************************/
void vAssertCalled(void) {

    int i;

	taskDISABLE_INTERRUPTS();

	/* Clear all LEDs */
  neorv32_gpio_port_set(0);

  neorv32_uart_puts(UART_HW_HANDLE, "FreeRTOS_FAULT: vAssertCalled called!\n");

	/* Flash the lowest 2 LEDs to indicate that assert was hit - interrupts are off
	here to prevent any further tick interrupts or context switches, so the
	delay is implemented as a busy-wait loop instead of a peripheral timer. */
	while(1) {
		for (i=0; i<(configCPU_CLOCK_HZ/100); i++) {
			__asm volatile( "nop" );
		}
		neorv32_gpio_pin_toggle(0);
		neorv32_gpio_pin_toggle(1);
	}
}