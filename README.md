# ARM Assembly Learning — STM32F411 Nucleo

This repository documents a step-by-step learning journey in **ARM Assembly** for **ARM Cortex-M** microcontrollers.  
Each subfolder is a self-contained **STM32CubeIDE** project targeting the **STM32F411RE Nucleo** board and focuses on one concept at a time.

---

## 📂 Project Index

| No. | Lesson | Summary |
|-----|--------|---------|
| 1 | [Using a Startup File](./01_using_startup_file) | Basic register operations with default startup. |
| 2 | [No Startup File](./02_no_startup_file) | Manual reset handler without startup file. |
| 3 | [Renaming Registers](./03_renaming_registers) | Using `.req` to alias registers. |
| 4 | [Allocating Memory](./04_allocating_memory) | Reserving memory with `.space`. |
| 5 | [Swapping Registers](./05_swapping_registers) | XOR-based register swap. |
| 6 | [Simple Equations](./06_simple_equations) | Using `.equ` constants in calculations. |
| 7 | [Import From C](./07_import_from_c) | Calling a C function from assembly. |
| 8 | [Export From ASM](./08_export_from_asm) | Calling an assembly function from C. |

---

## 🛠 Environment

- **Board:** STM32F411RE Nucleo  
- **Core/Architecture:** ARM Cortex-M4 (ARMv7-M)  
- **IDE:** STM32CubeIDE (Eclipse/CDT)  
- **Toolchain:** `arm-none-eabi-gcc`, `arm-none-eabi-as` (GNU)  
- **Language:** ARM assembly (GNU `gas` syntax)


