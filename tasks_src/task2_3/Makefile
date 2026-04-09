# Application makefile.
# Use this makefile to configure all relevant CPU / compiler options.

# Override the default RISC-V GCC prefix
RISCV_PREFIX ?= riscv32-unknown-elf-

# Additional sources
APP_SRC += $(wildcard ./src/*.c) $(wildcard ./lib/src/*.c)
APP_INC += -I ./lib/inc

# ----------------------------------------------------------------------------
# FreeRTOS
# -----------------------------------------------------------------------------

# FreeRTOS home folder
FREERTOS_HOME ?= ../../FreeRTOS-Kernel

# Kernel
APP_SRC += $(wildcard $(FREERTOS_HOME)/*.c)
APP_INC += -I $(FREERTOS_HOME)/include

# RISC-V specifics

APP_SRC += $(wildcard  $(FREERTOS_HOME)/portable/GCC/RISC-V/*.c)
APP_SRC += $(FREERTOS_HOME)/portable/GCC/RISC-V/portASM.S
APP_INC += -I $(FREERTOS_HOME)/portable/GCC/RISC-V

# Heap management
APP_SRC += $(wildcard  $(FREERTOS_HOME)/portable/MemMang/heap_4.c)

# -----------------------------------------------------------------------------
# NEORV32
# -----------------------------------------------------------------------------

# Set path to NEORV32 root directory
NEORV32_HOME ?= /media/sf_neorv32

# Chip-specific configuration
APP_INC += -I $(FREERTOS_HOME)/portable/GCC/RISC-V/chip_specific_extensions/RV32I_CLINT_no_extensions
ASM_INC += -I $(FREERTOS_HOME)/portable/GCC/RISC-V/chip_specific_extensions/RV32I_CLINT_no_extensions

# Override the default CPU ISA
MARCH = rv32i_zicsr_zifencei
MABI  = ilp32

# Override default optimization goal
EFFORT = -Os

# Add extended debug symbols
USER_FLAGS += -ggdb -gdwarf-3
USER_FLAGS += -fpermissive

# Adjust processor IMEM size and base address
USER_FLAGS += -Wl,--defsym,__neorv32_rom_size=32k
USER_FLAGS += -Wl,--defsym,__neorv32_rom_base=0x00000000

# Adjust processor DMEM size and base address
USER_FLAGS += -Wl,--defsym,__neorv32_ram_size=8k
USER_FLAGS += -Wl,--defsym,__neorv32_ram_base=0x80000000

# Adjust maximum heap size
#USER_FLAGS += -Wl,--defsym,__neorv32_heap_size=1k

# Include the main NEORV32 makefile
include $(NEORV32_HOME)/sw/common/common.mk
