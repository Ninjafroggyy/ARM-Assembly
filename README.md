# ARM Assembly Learning — STM32F411 Nucleo

This repository documents a step-by-step learning journey in **ARM Assembly** for **ARM Cortex-M** microcontrollers.  
Each subfolder is a self-contained **STM32CubeIDE** project targeting the **STM32F411RE Nucleo** board and focuses on one concept at a time.

---

## 📂 Project Index

| No. | Lesson                                                         | Summary |
|-----|----------------------------------------------------------------|---------|
| 1 | [1 Using Startup File](./1_Using_Startup)                      | Basic register operations with default startup. |
| 2 | [2 No Startup File](./2_No_Startup)                            | Manual reset handler without startup file. |
| 3 | [3_Renaming_Registers](./3_Renaming_Registers)                 | Using `.req` to alias registers. |
| 4 | [4_Allocating_Space_in_Memory](./4_Allocating_Space_in_Memory) | Reserving memory with `.space`. |
| 5 | [5_Swapping_Register_Contents](./5_Swapping_Register_Contents) | XOR-based register swap. |
| 6 | [6_Simple_Equations](./6_Simple_Equations)                     | Using `.equ` constants in calculations. |
| 7 | [7_Import_From_C](./7_Import_From_C)                           | Calling a C function from assembly. |
| 8 | [8_Export_From_ASM](./8_Export_From_ASM)                       | Calling an assembly function from C. |


---

## 🛠 Environment

- **Board:** STM32F411RE Nucleo  
- **Core/Architecture:** ARM Cortex-M4 (ARMv7-M)  
- **IDE:** STM32CubeIDE (Eclipse/CDT)  
- **Toolchain:** `arm-none-eabi-gcc`, `arm-none-eabi-as` (GNU)  
- **Language:** ARM assembly (GNU `gas` syntax)


