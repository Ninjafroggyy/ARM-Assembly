
// ===============================
// RCC (Reset & Clock Control)
// ===============================
.equ RCC_BASE,         0x40023800                       // Base address of RCC peripheral block

.equ AHB1ENR_OFFSET,   0x30                             // Offset: AHB1 peripheral clock enable register
.equ RCC_AHB1ENR,     (RCC_BASE + AHB1ENR_OFFSET)       // Address of RCC_AHB1ENR (enables GPIOA clock, etc.)

.equ APB2ENR_OFFSET,   0x44                             // Offset: APB2 peripheral clock enable register
.equ RCC_APB2ENR,     (RCC_BASE + APB2ENR_OFFSET)       // Address of RCC_APB2ENR (enables ADC1 clock, etc.)

// ===============================
// GPIO common offsets
// ===============================
.equ MODER_OFFSET,     0x00                             // Offset: GPIO port mode register (MODER)
.equ BSRR_OFFSET,      0x18                             // Offset: GPIO bit set/reset register (BSRR)


// Clock enable bitmasks
.equ GPIOA_EN,        (1 << 0)                          // RCC_AHB1ENR bit 0: enable clock for GPIOA
.equ ADC1_EN,         (1 << 8)                          // RCC_APB2ENR bit 8: enable clock for ADC1

// ===============================
// GPIOA (LED on PA5 and ADC pin PA1)
// ===============================
.equ GPIOA_BASE,       0x40020000                       // Base address of GPIOA
.equ GPIOA_MODER,     (GPIOA_BASE + MODER_OFFSET)       // Address of GPIOA_MODER (configures pin modes)
.equ GPIOA_BSRR,      (GPIOA_BASE + BSRR_OFFSET)        // Address of GPIOA_BSRR (atomic bit set/reset)

// Mode values / masks for GPIOA pins
.equ MODER5_OUT,      (1 << 10)                         // Set MODER[11:10] = 01 for PA5 (output mode)
.equ MODER1_ANLG_SLT, 0xC                               // Set MODER[3:2]   = 11 for PA1 (analog mode)  (equiv. to (3 << 2))

// BSRR values to drive LED on PA5
.equ BSRR_5_SET,      (1 << 5)                          // Write to BSRR to set PA5 (LED on)
.equ BSRR_5_RESET,    (1 << 21)                         // Write to BSRR to reset PA5 (LED off) — reset bit index = pin + 16

// ===============================
// ADC1 registers (APB2 peripheral at 0x4001 2000)
// ===============================
.equ ADC1_BASE,        0x40012000                       // Base address of ADC1

.equ ADC1_SR_OFFSET,   0x00                             // Offset: status register (SR)
.equ ADC1_CR2_OFFSET,  0x08                             // Offset: control register 2 (CR2)
.equ ADC1_SQR1_OFFSET, 0x2C                             // Offset: regular sequence register 1 (SQR1)
.equ ADC1_SQR3_OFFSET, 0x34                             // Offset: regular sequence register 3 (SQR3)
.equ ADC1_DR_OFFSET,   0x4C                             // Offset: data register (DR)

.equ ADC1_SR,         (ADC1_BASE + ADC1_SR_OFFSET)      // Address of ADC1_SR
.equ ADC1_CR2,        (ADC1_BASE + ADC1_CR2_OFFSET)     // Address of ADC1_CR2
.equ ADC1_SQR1,       (ADC1_BASE + ADC1_SQR1_OFFSET)    // Address of ADC1_SQR1
.equ ADC1_SQR3,       (ADC1_BASE + ADC1_SQR3_OFFSET)    // Address of ADC1_SQR3
.equ ADC1_DR,         (ADC1_BASE + ADC1_DR_OFFSET)      // Address of ADC1_DR


// ADC bit fields and config values
.equ ADC1_CR2_ON,     (1 << 0)                          // CR2: ADON (enable ADC)
.equ CR2_SWSTART,     (1 << 30)                         // CR2: start conversion of regular channels
.equ SR_EOC,          (1 << 1)                          // SR: End Of Conversion (note: many STM32F4 use bit 1 for EOC)

.equ SQR3_CNF,         1                                // SQR3: first conversion on channel 1 (PA1)
.equ SQR1_CNF,         0                                // SQR1: length field L = 0 → 1 conversion in the regular sequence

// ===============================
// Threshold (example) and other app-level constants
// ===============================
.equ SENS_THRESH,    3000                               // Example threshold to compare against ADC reading


// ----------------------------------------------------
//                 Directives / Sections
// ----------------------------------------------------
			.syntax unified
			.cpu cortex-m4
			.fpu softvfp
			.thumb

// Code Section
			.section .text

// Global calls for external files to call
			.global adc_init
			.global adc_read
			.global led_init
			.global led_control


adc_init:
			/* Enable clock access to ADC pin's GPIO port */
			ldr r0, =RCC_AHB1ENR			// Load address of RCC_AHB1ENR into r0
			ldr r1, [r0]					// Load value at address found in r0 into r1
			orr r1, r1, #GPIOA_EN			// Set bit 0 in r1 (enable the GPIOA clock) while keeping other bits unchanged
			str r1, [r0]					// Store content in r1 at address found in r0

			/* Set ADC pin, PA1 as analog pin */
			ldr r0, =GPIOA_MODER			// Load the address of GPIOA_MODER into r0
			ldr r1, [r0]					// Load the current 32-bit GPIOA_MODER into r1
			orr r1, r1, #MODER1_ANLG_SLT	// OR r1 with 0xC → sets MODER[3:2] = 11, making PA1 analog mode
			str r1, [r0]					// Store r1 back to GPIOA_MODER (apply analog mode)

			/* Enable clock access to the ADC */
			ldr r0, =RCC_APB2ENR			// Load address of RCC_AHB1ENR into r0
			ldr r1, [r0]					// Load value at address found in r0 into r1
			orr r1, r1, #ADC1_EN			// Bitwise OR r1 with ADC1_EN (set bit 8) and store result in r1 (enable ADC1 clock)
			str r1, [r0]					// Store content in r1 at address found in r0

			/* Select software trigger */
			ldr r0, =ADC1_CR2				// Load the address of ADC1_CR2 into r0
			ldr r1, =0x00000000				// Load immediate value 0 into r1
			str r1, [r0]					// Store r1 to ADC1_CR2 (software trigger, continuous disabled, etc.)

			/* Set conversion sequence starting channel */
			ldr r0, =ADC1_SQR3				// Load the address of ADC1_SQR3 into r0
			mov r1, #SQR3_CNF				// Move the immediate value SQR3_CNF (1) into r1
			str r1, [r0]					// Store r1 to ADC1_SQR3 (first conversion = channel 1)

			/* Set conversion sequence length */
			ldr r0, =ADC1_SQR1				// Load the address of ADC1_SQR1 into r0
			mov r1, #SQR1_CNF				// Move the immediate value SQR1_CNF (0) into r1
			str r1, [r0]					// Store r1 to ADC1_SQR1 (regular sequence length = 1)

			/* Enable ADC module */
			ldr r0, =ADC1_CR2				// Load address of ADC1_CR2 into r0
			ldr r1, [r0]					// Load value at address found in r0 into r1
			orr r1, r1, #ADC1_CR2_ON		// Bitwise OR r1 with ADC1_CR2_ON (set ADON bit) and store result in r1
			str r1, [r0]					// Store content in r1 at address found in r0

			bx lr							// Return from subroutine

adc_read:
			/* Start conversion */
			ldr r0, =ADC1_CR2				// Load address of ADC1_CR2 into r0
			ldr r1, [r0]					// Load value at address found in r0 into r1
			orr r1, r1, #CR2_SWSTART		// Bitwise OR r1 with CR2_SWSTART (set SWSTART) and store result in r1
			str r1, [r0]					// Store content in r1 at address found in r0

conversion:
			/* Wait for conversion to be complete */
			ldr r0, =ADC1_SR				// Load the address of ADC1_SR into r0
			ldr r1, [r0]					// Load the current 32-bit value from ADC1_SR into r1
			and r1, r1, #SR_EOC				// Bitwise AND r1 with SR_EOC (isolate EOC bit); result in r1
			cmp r1, #0x00					// Compare r1 with 0 (check if EOC is still 0)
			beq conversion					// If equal (EOC not set), branch back and keep polling

			/* Read content of ADC data register */
			ldr r2, =ADC1_DR				// Load the address of ADC1_DR (data register) into r2
			ldr r0, [r2]					// Load the 16-bit/32-bit result from ADC1_DR into r0 (ADC conversion value)

			bx lr							// Return from subroutine

led_init:
			/*Enable clock access to GPIOA*/
			ldr r0, =RCC_AHB1ENR			// Load address of RCC_AHB1ENR into r0
			ldr r1, [r0]					// Load value at address found in r0 into r1
			orr r1, r1, #GPIOA_EN			// Set bit 0 in r1 (enable the GPIOA clock) while keeping other bits unchanged
			str r1, [r0]					// Store content in r1 at address found in r0

			/* Set PA5 as output pin */
			ldr r0, =GPIOA_MODER			// Load address of GPIOA_MODER into r0
			ldr r1, [r0]					// Load value at address found in r0 into r1
			orr r1, r1, #MODER5_OUT			// Set the bits that configure PA5 as an output (bits 11:10 = 01) while leaving other pins unchanged
			str r1, [r0]					// Store content in r1 at address found in r0

			bx lr							// Return from subroutine

led_control:
			ldr r1, =SENS_THRESH			// Load the address-immediate of SENS_THRESH into r1, then the assembler places the literal
			cmp r0, r1						// Compare ADC reading in r0 with threshold in r1
			bgt turn_led_on					// Branch to turn_led_on if ADC value is greater than SENS_THRESH
			blt turn_led_off				// Branch to turn_led_off if ADC value is less than SENS_THRESH

			bx lr							// Return from subroutine

turn_led_on:
			ldr r5, =GPIOA_BSRR				// Load the address of GPIOA_BSRR into r5
			mov r1, #BSRR_5_SET				// Move the SET value for PA5 into r1
			str r1, [r5]					// Store r1 to BSRR (set PA5 → LED on)

			bx lr							// Return from subroutine

turn_led_off:
			ldr r5, =GPIOA_BSRR				// Load the address of GPIOA_BSRR into r5
			mov r1, #BSRR_5_RESET			// Move the RESET value for PA5 into r1
			str r1, [r5]					// Store r1 to BSRR (reset PA5 → LED off)

			bx lr							// Return from subroutine


stop:
			b stop							// Branch to self


			.align
			.end							// Required to end program

