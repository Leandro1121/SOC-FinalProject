#include <neorv32.h>

#define PONG_IP_BASE 0x40000000u
#define BAUD_RATE 19200

// Buttons to Bit mapping 
#define P1_DN (1u << 0)
#define P1_UP (1u << 1)
#define P2_DN (1u << 2)
#define P2_UP (1u << 3)
#define START (1u << 4)

static void delay_ms(uint32_t time_ms) {
	neorv32_aux_delay_ms(neorv32_sysinfo_get_clk(), time_ms);
}

int main(void) {

neorv32_uart0_setup(BAUD_RATE, 0);
neorv32_uart0_puts("\n-- Pong Game Initializing --\n");

// setting axi gpios as outputs
neorv32_cpu_store_unsigned_word(PONG_IP_BASE + 0x4u, 0x00000000u);

uint32_t prev_start = 0;

while (1) {

uint32_t buttons = neorv32_gpio_port_get();
uint32_t pong_cmd = 0;

if (buttons & 0x01u) pong_cmd |= P1_DN; 
if (buttons & 0x02u) pong_cmd |= P1_UP;
if (buttons & 0x04u) pong_cmd |= P2_DN;
if (buttons & 0x08u) pong_cmd |= P2_UP;
if (buttons & 0x10u) pong_cmd |= START;

uint32_t started = (pong_cmd & START) ? 1u : 0u;



if (started && !prev_start) {
neorv32_uart0_puts("Pong game START signal active\n");
} else if (!started && prev_start) {
neorv32_uart0_puts("Game paused\n");
}
prev_start = started;

neorv32_cpu_store_unsigned_word(PONG_IP_BASE + 0x0u, pong_cmd);

delay_ms(20);
}
return 0;
}
