# NEORV32 FreeRTOS + DDR3 Project

A FreeRTOS application running on the NEORV32 RISC-V soft-core processor with DDR3 memory support, targeting a Xilinx 7-Series FPGA.

---

## Prerequisites

Before building, ensure the following are installed and configured on your system:

- RISC-V GCC toolchain (`riscv32-unknown-elf-gcc`)
- GNU Make
- Vivado (for FPGA synthesis and MIG 7-Series IP)
- Git

---

### 1. Clone and Initialize Submodules

FreeRTOS is included as a Git submodule. After cloning the repository, run:

```bash
git submodule update --init --recursive
```

This will pull the FreeRTOS source into the correct subdirectory.

---

### 2. Set the NEORV32 Home Directory

The Makefile uses `NEORV32_HOME` to locate the NEORV32 source tree. By default it points to the VirtualBox shared folder mount:

```bash
NEORV32_HOME ?= /media/sf_neorv32
```

If you are **not** using VirtualBox, or your shared folder is mounted at a different path, override this variable when calling Make:

```bash
make NEORV32_HOME=/path/to/your/neorv32
```

Or export it as an environment variable to avoid passing it every time:

```bash
export NEORV32_HOME=/path/to/your/neorv32
```

---

### 3. Add the RISC-V Toolchain to your PATH

The build system expects the RISC-V toolchain binaries to be available on your PATH:

```bash
export PATH=/opt/riscv/bin:$PATH
```

Add this line to your `~/.bashrc` or `~/.zshrc` to make it permanent.

Verify the toolchain is found:

```bash
riscv32-unknown-elf-gcc --version
```

---

### 4. Build the Project

```bash
make clean
make
```

The compiled ELF and binary will be placed in the `build/` directory.

---

## DDR3 Memory Interface

The DDR3 interface is implemented using the **Xilinx MIG 7-Series** IP core generated through Vivado. An AXI SmartConnect bridges the NEORV32 memory bus to the MIG's AXI4 slave port.

### Clock Configuration

The design requires three clock frequencies. Ensure your Clocking Wizard is configured accordingly:

| Clock | Frequency | Purpose |
|-------|-----------|---------|
| System clock | 100 MHz | General logic |
| MIG reference clock | 200 MHz | MIG 7-Series reference |
| DDR3 interface clock | 333.333 MHz | DDR3 data rate |

### Reset Behaviour

The DDR3 system reset is gated by the Clocking Wizard's `locked` signal — the memory interface will not come out of reset until all clocks have stabilized. The AXI SmartConnect handles reset propagation across the NEORV32 and MIG clock domains automatically.

> ⚠️ If the DDR3 fails to initialize, first check that the `locked` signal from the Clocking Wizard is being asserted correctly before investigating the MIG calibration status.

---

## Project Structure

```
task4/
├── build/
├── lib/
│  ├── inc/
│  │   ├── aes_cfs.h
│  │   ├── crypto_utils.h
│  │   ├── ddr3_mem.h
│  │   ├── freertos_neo_hooks.h
│  │   ├── freertos_neo_interrupts.h
│  │   ├── freertos_neo_tasks.h
│  │   ├── FreeRTOSConfig.h
│  │   ├── project_constants.h
│  │   └── trng.h
│  └── src/
│      ├── aes_cfs.c
│      ├── crypto_utils.c
│      ├── ddr3_mem.c
│      ├── freertos_neo_hooks.c
│      ├── freertos_neo_interrupts.c
│      ├── freertos_neo_tasks.c
│      ├── project_constants.c
│      └── trng.c
└── src/
|   └── main.c
|
├── Makefile
└── README.md
```

---

## Common Issues

**Toolchain not found**
Ensure `/opt/riscv/bin` is on your PATH and `riscv32-unknown-elf-gcc --version` returns a valid version.

**FreeRTOS source missing**
Run `git submodule update --init --recursive` — the submodule is not included in the repository directly.

**DDR3 calibration failure in hardware**
Check that all three clocks are locked before reset is released. Inspect the MIG's `init_calib_complete` signal in the ILA or via a status register.

**Wrong NEORV32_HOME path**
Pass the correct path explicitly: `make NEORV32_HOME=/your/path`
