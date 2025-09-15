
// --- RCC (Reset and Clock Control) registers on AHB1 bus ---
.equ RCC_BASE, 0x40023800    							// Base address of RCC peripheral (on AHB1 bus)
.equ AHB1ENR_OFFSET, 0x30          						// Offset for AHB1 peripheral clock enable register
.equ RCC_AHB1ENR, (RCC_BASE + AHB1ENR_OFFSET)  			// Address of AHB1ENR register (enables GPIO clocks, etc.)

// --- GPIOA registers on AHB1 bus ---
.equ GPIOA_BASE,      0x40020000    					// Base address of GPIOA peripheral (on AHB1 bus)

.equ GPIOA_MODER_OFFSET, 0x00       					// Offset for GPIO port mode register (MODER)
.equ GPIOA_MODER, (GPIOA_BASE + GPIOA_MODER_OFFSET) 	// Address of GPIOA_MODER (sets pin modes)

.equ GPIOA_ODR_OFFSET, 0x14         					// Offset for GPIO port output data register (ODR)
.equ GPIOA_ODR, (GPIOA_BASE + GPIOA_ODR_OFFSET)    		// Address of GPIOA_ODR (writes output values)

// --- Bit definitions ---
.equ GPIOA_EN, (1 << 0) 	          					// Bit 0 in RCC_AHB1ENR: enable clock for GPIOA
.equ MODER5_OUT, (1 << 10)          					// MODER register: configure pin 5 as output (01 at bits 11:10)
.equ LED_ON, (1U << 5)	         	 					// ODR register: set bit 5 high (turn LED on)


// Directives
			.syntax unified
			.cpu cortex-m4
			.fpu softvfp
			.thumb

// Code Section
			.section .text

// Global calls for external files to call
			.global __main

__main:

			/*Enable clock access to GPIOA*/
			ldr r0, =RCC_AHB1ENR		// Load address of RCC_AHB1ENR into r0
			ldr r1, [r0]				// Load value at address found in r0 into r1
			orr r1, r1, #GPIOA_EN		// Set bit 0 in r1 (enable the GPIOA clock) while keeping other bits unchanged
			str r1, [r0]				// Store content in r1 at address found in r0

			ldr r0, =GPIOA_MODER		// Load address of GPIOA_MODER into r0
			ldr r1, [r0]				// Load value at address found in r0 into r1
			orr r1, r1, #MODER5_OUT		// Set the bits that configure PA5 as an output (bits 11:10 = 01) while leaving other pins unchanged
			str r1, [r0]				// Store content in r1 at address found in r0

			ldr r0, =GPIOA_ODR			// Load address of GPIOA_ODR into r0
			ldr r1, [r0]				// Load value at address found in r0 into r1
			orr r1, r1, #LED_ON			// Set bit 5 in r1 (drive PA5 high) while keeping other pin states unchanged
			str r1, [r0]				// Store content in r1 at address found in r0

			bx lr						// Return from subroutine (branch to address in link register)


			.align
			.end						// Required to end program

