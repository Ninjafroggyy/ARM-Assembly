
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


// --- GPIOC (button input) ---
.equ GPIOC_BASE, 0x40020800								// Base address of the GPIOC peripheral (on the AHB1 bus)
.equ GPIOC_MODER, (GPIOC_BASE + MODER_OFFSET) 			// Address of GPIOC_MODER (sets pin modes)

.equ IDR_OFFSET, 0x10									// Offset of the GPIO input data register (IDR)
.equ GPIOC_IDR, (GPIOC_BASE + IDR_OFFSET)				// Full address of GPIOC_IDR (read current logic level on PC pins)



// --- Bit definitions ---
.equ GPIOA_EN, (1 << 0) 	          					// Bit 0 in RCC_AHB1ENR: enable clock for GPIOA
.equ GPIOC_EN, (1<<2)									// Bit 2 in RCC_AHB1ENR: enable clock for GPIOC

.equ MODER5_OUT, (1 << 10)          					// MODER register: configure pin 5 as output (01 at bits 11:10)
.equ MODER13_MASK, (3 << 26)    						// Mask for bits 27:26, sets PC13 to input mode (00)

.equ BSRR_5_SET, (1<<5)									// BSRR register: set PA5 high (LED on)
.equ BSRR_5_RESET, (1<<21)								// BSRR register: reset PA5 low (LED off)

.equ BTN_ON, 0x0000										// Result after masking when PC13 reads logic 0 (bit 13 clear)
.equ BTN_OFF, 0x2000 									// Result after masking when PC13 reads logic 1 (bit 13 set)
.equ BTN_PIN, 0x2000									// Mask for button pin PC13 (bit 13)

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
			bl gpio_init				// Branch with link to gpio_init (call setup routine to configure clocks and pin modes)

loop:
			bl get_input				// Branch with link to get_input (call to read and mask PC13 state into r0)

			cmp r0, #BTN_ON				// Compare value in r0 with BTN_ON (0x0000)
			beq turn_led_on				// Branch to turn_led_on if r0 is equal to BTN_ON

			cmp r0, #BTN_OFF			// Compare value in r0 with BTN_OFF (0x2000)
			beq turn_led_off			// Branch to turn_led_off if r0 is equal to BTN_OFF

			b loop						// Branch back to loop

turn_led_on:
			mov r1, #0					// Move immediate 0 into r1 (clears r1; note: next instruction overwrites it anyway)
			ldr r2, =GPIOA_BSRR			// Load the address of GPIOA_BSRR into r2 (destination for set/reset writes)
			mov r1, #BSRR_5_SET			// Move the SET value for PA5 into r1 (this value sets PA5 when written to BSRR)
			str r1, [r2]				// Store r1 to the memory address in r2 (write to BSRR → PA5 goes high, LED on)

			b loop						// Branch back to loop

turn_led_off:
			mov r1, #0					// Move immediate 0 into r1 (clears r1; note: next instruction overwrites it anyway)
			ldr r2, =GPIOA_BSRR			// Load the address of GPIOA_BSRR into r2 (destination for set/reset writes)
			mov r1, #BSRR_5_RESET		// Move the RESET value for PA5 into r1 (this value resets PA5 when written to BSRR)
			str r1, [r2]				// Store r1 to the memory address in r2 (write to BSRR → PA5 goes low, LED off)

			b loop						// Branch back to loop


get_input:
			ldr r1, =GPIOC_IDR			// Load the address of GPIOC_IDR (input data register) into r1
			ldr r0, [r1]				// Load the 32-bit value from the address in r1 into r0 (read all PC pin states)
			and r0, r0, #BTN_PIN		// Perform bitwise AND of r0 with BTN_PIN (mask all bits except PC13); result in r0

			bx lr						// Branch to the address in lr (return to caller) with masked state in r0


gpio_init:
			/*Enable clock access to GPIOA*/
			ldr r0, =RCC_AHB1ENR		// Load address of RCC_AHB1ENR into r0
			ldr r1, [r0]				// Load value at address found in r0 into r1
			orr r1, r1, #GPIOA_EN		// Set bit 0 in r1 (enable the GPIOA clock) while keeping other bits unchanged
			str r1, [r0]				// Store content in r1 at address found in r0

			/* Set PA5 as output pin */
			ldr r0, =GPIOA_MODER		// Load address of GPIOA_MODER into r0
			ldr r1, [r0]				// Load value at address found in r0 into r1
			orr r1, r1, #MODER5_OUT		// Set the bits that configure PA5 as an output (bits 11:10 = 01) while leaving other pins unchanged
			str r1, [r0]				// Store content in r1 at address found in r0

			/*Enable clock access to GPIOC*/
			ldr r0, =RCC_AHB1ENR		// Load address of RCC_AHB1ENR into r0
			ldr r1, [r0]				// Load value at address found in r0 into r1
			orr r1, r1, #GPIOC_EN		// Set bit 2 in r1 (enable the GPIOC clock) while keeping other bits unchanged
			str r1, [r0]				// Store content in r1 at address found in r0

			/* Set PC13 as input pin */
			ldr r0, =GPIOC_MODER        // Load address of GPIOC_MODER into r0
			ldr r1, [r0]                // Load value at address found in r0 into r1
			bic r1, r1, #MODER13_MASK   // Clear the two mode bits for PC13 (bits 27:26) so they become 00, which configures PC13 as an input
			str r1, [r0]                // Store content in r1 at address found in r0

			bx lr						// Branch to the address in lr (return to caller) with masked state in r0
stop:
			b stop						// Branch to self


			.align
			.end						// Required to end program

