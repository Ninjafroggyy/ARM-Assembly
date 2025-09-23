
// ===============================
// RCC (Reset & Clock Control)
// ===============================
.equ RCC_BASE,          0x40023800                       // Base address of RCC peripheral block

.equ AHB1ENR_OFFSET,    0x30                             // Offset: AHB1 peripheral clock enable register
.equ RCC_AHB1ENR,      (RCC_BASE + AHB1ENR_OFFSET)       // Address of RCC_AHB1ENR (enable GPIO clocks)

.equ APB1ENR_OFFSET,    0x40                             // Offset: APB1 peripheral clock enable register
.equ RCC_APB1ENR,      (RCC_BASE + APB1ENR_OFFSET)       // Address of RCC_APB1ENR (enable APB1 peripherals, e.g. TIM2)

// RCC bitmasks
.equ GPIOA_EN,         (1 << 0)                         // RCC_AHB1ENR bit 0 → enable GPIOA clock
.equ GPIOC_EN,         (1 << 2)                         // RCC_AHB1ENR bit 2 → enable GPIOC clock (unused here)
.equ TIM2_EN,          (1 << 0)                         // RCC_APB1ENR bit 0 → enable TIM2 clock


// ===============================
// GPIOA (LED on PA5)
// ===============================
.equ GPIOA_BASE,        0x40020000                       // Base address of GPIOA

// GPIOA register addresses
.equ MODER_OFFSET,      0x00                             // Offset: GPIO port mode register (MODER)
.equ GPIOA_MODER,      (GPIOA_BASE + MODER_OFFSET)       // Address of GPIOA_MODER (pin mode config)

.equ BSRR_OFFSET,       0x18                             // Offset: GPIO port bit set/reset register (BSRR)
.equ GPIOA_BSRR,       (GPIOA_BASE + BSRR_OFFSET)        // Address of GPIOA_BSRR (atomic bit set/reset)

// GPIOA bitmasks
.equ MODER5_OUT,       (1 << 10)                         // MODER: configure PA5 as output (MODER[11:10] = 01)
.equ BSRR_5_SET,       (1 << 5)                          // BSRR: write to lower half → set PA5 high (LED on)
.equ BSRR_5_RESET,     (1 << 21)                         // BSRR: write to upper half → reset PA5 low (LED off)


// ===============================
// TIM2 (basic timer, APB1 bus)
// ===============================
.equ TIM2_BASE,         0x40000000                       // Base address of TIM2

// TIM2 register addresses
.equ CR1_OFFSET,        0x00                             // Offset: control register 1
.equ TIM2_CR1,         (TIM2_BASE + CR1_OFFSET)          // Address of TIM2_CR1 (control, enable/disable)

.equ CNT_OFFSET,        0x24                             // Offset: counter
.equ TIM2_CNT,         (TIM2_BASE + CNT_OFFSET)          // Address of TIM2_CNT (current counter value)

.equ PSC_OFFSET,        0x28                             // Offset: prescaler
.equ TIM2_PSC,         (TIM2_BASE + PSC_OFFSET)          // Address of TIM2_PSC (clock divider)

.equ ARR_OFFSET,        0x2C                             // Offset: auto-reload
.equ TIM2_ARR,         (TIM2_BASE + ARR_OFFSET)          // Address of TIM2_ARR (timer period)

.equ SR_OFFSET,         0x10                             // Offset: status register
.equ TIM2_SR,          (TIM2_BASE + SR_OFFSET)           // Address of TIM2_SR (status flags)

// TIM2 bitmasks
.equ CR1_CEN,          (1 << 0)                         // CR1: CEN bit → enable counter
.equ SR_UIF,           (1 << 0)                         // SR: UIF flag → update interrupt flag (set when ARR reached)


// ===============================
// Program Directives
// ===============================
			.syntax unified
			.cpu cortex-m4
			.fpu softvfp
			.thumb


// ===============================
// Code Section
// ===============================
			.section .text
			.global __main

__main:
			bl  gpio_init                                    // Configure PA5 as output
	        bl  timer_init                                   // Configure TIM2 as a time base
	        bl  led_blink                                    // Start LED blink loop

timer_init:
			/* Enable clock access to TIM2 */
	        ldr r0, =RCC_APB1ENR                             // Load address of RCC_APB1ENR into r0
	        ldr r1, [r0]                                     // Load current value at RCC_APB1ENR into r1
	        orr r1, r1, #TIM2_EN                             // Set bit 0 in r1 (enable TIM2 clock)
	        str r1, [r0]                                     // Store updated value back to RCC_APB1ENR

	        /* Set prescaler so TIM2 runs at 10 kHz */
	        ldr r0, =TIM2_PSC                                // Load address of TIM2_PSC into r0
	        mov r1, #(1600 - 1)                              // Put 1599 into r1 (16 MHz / 1600 = 10 kHz)
	        str r1, [r0]                                     // Store r1 to TIM2_PSC

	        /* Set auto-reload so overflow occurs every 1 second */
	        ldr r0, =TIM2_ARR                                // Load address of TIM2_ARR into r0
	        mov r1, #(10000 - 1)                             // Put 9999 into r1 (10 kHz / 10000 = 1 Hz)
	        str r1, [r0]                                     // Store r1 to TIM2_ARR

	        /* Reset the counter to 0 */
	        ldr r0, =TIM2_CNT                                // Load address of TIM2_CNT into r0
	        mov r1, #0                                       // Put 0 into r1
	        str r1, [r0]                                     // Store 0 into TIM2_CNT

	        /* Enable TIM2 counter */
	        ldr r0, =TIM2_CR1                                // Load address of TIM2_CR1 into r0
	        mov r1, #CR1_CEN                                 // Put 1 (CEN) into r1
	        str r1, [r0]                                     // Store r1 into TIM2_CR1 (counter enabled)

	        bx lr                                            // Return from subroutine


_wait:
        	ldr r1, =TIM2_SR                                 // Load address of TIM2_SR into r1

loop:
	        ldr r2, [r1]                                     // Load value of TIM2_SR into r2
	        and r2, r2, #SR_UIF                              // Mask all bits except UIF
	        cmp r2, #0                                       // Compare result with 0
	        beq loop                                         // If UIF is 0 → keep looping until it becomes 1

	        /* Clear UIF after detecting it */
	        ldr r3, [r1]                                     // Load current TIM2_SR into r3
	        bic r3, r3, #SR_UIF                              // Clear UIF bit in r3
	        str r3, [r1]                                     // Write back to TIM2_SR (UIF cleared)

	        bx lr                                            // Return from subroutine


led_blink:
			/* Turn LED on (set PA5 high) */
	        ldr r4, =GPIOA_BSRR                              // Load address of GPIOA_BSRR into r4
	        mov r1, #BSRR_5_SET                              // Put SET value for PA5 into r1
	        str r1, [r4]                                     // Write r1 to GPIOA_BSRR (PA5 high)
	        bl  _wait                                        // Wait for TIM2 overflow

	        /* Turn LED off (reset PA5 low) */
	        ldr r4, =GPIOA_BSRR                              // Load address of GPIOA_BSRR into r4
	        mov r1, #BSRR_5_RESET                            // Put RESET value for PA5 into r1
	        str r1, [r4]                                     // Write r1 to GPIOA_BSRR (PA5 low)
	        bl  _wait                                        // Wait for TIM2 overflow

	        bl  led_blink                                    // Repeat forever


gpio_init:
			/* Enable clock access to GPIOA */
	        ldr r0, =RCC_AHB1ENR                             // Load address of RCC_AHB1ENR into r0
	        ldr r1, [r0]                                     // Load current value of RCC_AHB1ENR into r1
	        orr r1, r1, #GPIOA_EN                            // Set bit 0 in r1 (enable GPIOA clock)
	        str r1, [r0]                                     // Store updated value back to RCC_AHB1ENR

	        /* Configure PA5 as output */
	        ldr r0, =GPIOA_MODER                             // Load address of GPIOA_MODER into r0
	        ldr r1, [r0]                                     // Load current MODER value into r1
	        orr r1, r1, #MODER5_OUT                          // Set MODER[11:10] = 01 (PA5 as output)
	        str r1, [r0]                                     // Write updated value back to GPIOA_MODER

	        bx lr                                            // Return from subroutine


			.align
			.end						// Required to end program

