# Application makefile.
# AES: software + CFS hardware + ISA
# GIFT: software only

MARCH=rv32i_zicsr_zifencei_zkne_zknd_zbkx_zbkb
MABI=ilp32

RISCV_PREFIX ?= riscv32-unknown-elf-
EFFORT = -Os

USER_FLAGS += -ggdb -gdwarf-3
USER_FLAGS += -Wl,--defsym,__neorv32_rom_size=16k
USER_FLAGS += -Wl,--defsym,__neorv32_ram_size=8k

# Exclude the old GIFT hardware wrapper from the build.
APP_SRC += $(filter-out ./gift_cfs.c, $(wildcard ./*.c)) ./aes_isa.S
APP_INC += -I.

NEORV32_HOME ?= /mnt/hgfs/neorv32
include $(NEORV32_HOME)/sw/common/common.mk

override CC = $(RISCV_PREFIX)g++
USER_FLAGS += -std=c++11
