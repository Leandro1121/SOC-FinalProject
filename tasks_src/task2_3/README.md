# Task 2 Part 3

Run the git submodule command to get the FreeRTOS submodule into the repo 
```bash
git submodule update --init --recursive
```

Set MakeFile NEO home directory if not using Virtual Box, or using different mount settings 
```bash
NEORV32_HOME ?= /media/sf_neorv32
``` 

Remember to have the toolchain in your path variable 
```bash
export PATH=/opt/riscv/bin:$PATH 
```