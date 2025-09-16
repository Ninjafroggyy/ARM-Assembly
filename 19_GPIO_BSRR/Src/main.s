
// --- RCC (Reset and Clock Control) registers on AHB1 bus ---
.equ RCC_BASE, 0x40023800    							// Base address of RCC peripheral (on AHB1 bus)
.equ AHB1ENR_OFFSET, 0x30          						// Offset for AHB1 peripheral clock enable register
.equ RCC_AHB1ENR, (RCC_BASE + AHB1ENR_OFFSET)  			// Address of AHB1ENR register (enables GPIO clocks, etc.)

// --- GPIOA registers on AHB1 bus ---
.equ GPIOA_BASE,      0x40020000    					// Base address of GPIOA peripheral (on AHB1 bus)

.equ MODER_OFFSET, 0x00       							// Offset for GPIO port mode register (MODER)
.equ GPIOA_MODER, (GPIOA_BASE + MODER_OFFSET) 			// Address of GPIOA_MODER (sets pin modes)

.equ BSRR_OFFSET, 0x18									// Offset for GPIO port bit set/reset register (BSRR)
.equ GPIOA_BSRR, (GPIOA_BASE + BSRR_OFFSET)				// Address of GPIOA_BSRR (atomic set/reset of output bits)

// --- Bit definitions ---
.equ GPIOA_EN, (1 << 0) 	          					// Bit 0 in RCC_AHB1ENR: enable clock for GPIOA
.equ MODER5_OUT, (1 << 10)          					// MODER register: configure pin 5 as output (01 at bits 11:10)
.equ ONESEC, 5333333									// Delay loop count value (~1 second at system clock speed)

.equ BSRR_5_SET, (1<<5)									// BSRR register: set PA5 high (LED on)
.equ BSRR_5_RESET, (1<<21)								// BSRR register: reset PA5 low (LED off)

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

			mov r1, #0					// Move 0 into r1
			ldr r2, =GPIOA_BSRR			// Load address of GPIOA_BSRR into r2

blink:
			mov r1, #BSRR_5_SET			// Load value into r1 that sets PA5 high when written to GPIOA_BSRR
			str r1, [r2]				// Store r1 to GPIOA_ODR (turn LED on)
			ldr r3, =ONESEC				// Load loop count into r3 (very large right now)
			bl delay					// Call delay (will return here when r3 hits 0)

			mov r1, #BSRR_5_RESET		// Load value into r1 that resets PA5 low when written to GPIOA_BSRR
			str r1, [r2]				// Store r1 to GPIOA_ODR (turn LED off)
			ldr r3, =ONESEC				// Reload loop count
			bl delay					// Another delay

			b blink						// Repeat forever

delay:
			subs r3, r3, #1				// Subtract 1 from value in r3, update flags, and place result into r3
			bne delay					// Branch to delay if z flag is not 0

			bx lr						// Return from subroutine (branch to address in link register)


			.align
			.end						// Required to end program

