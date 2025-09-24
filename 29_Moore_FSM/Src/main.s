// ===============================
// RCC (Reset & Clock Control)
// ===============================
.equ RCC_BASE,            0x40023800          			// Base address of the RCC peripheral block
.equ AHB1ENR_OFFSET,      0x30                			// Offset of the AHB1 peripheral clock enable register (RCC_AHB1ENR)
.equ RCC_AHB1ENR,        (RCC_BASE + AHB1ENR_OFFSET)  	// Address of RCC_AHB1ENR (used to enable GPIO port clocks)

// Clock enable bit masks (RCC_AHB1ENR)
.equ GPIOA_EN,           (1 << 0)            			// Set bit 0 to turn on the GPIOA peripheral clock
.equ GPIOC_EN,           (1 << 2)            			// Set bit 2 to turn on the GPIOC peripheral clock


// ===============================
// GPIO base addresses (A for lights, C for sensors)
// ===============================
.equ GPIOA_BASE,          0x40020000          			// Base address of GPIOA (traffic lights live on PA4..PA9)
.equ GPIOC_BASE,          0x40020800          			// Base address of GPIOC (car sensors live on PC0..PC1)


// ===============================
// Common GPIO register offsets
// ===============================
.equ MODER_OFFSET,        0x00                			// Offset: GPIOx_MODER (pin mode register)
.equ ODR_OFFSET,          0x14                			// Offset: GPIOx_ODR   (output data register)
.equ BSRR_OFFSET,         0x18                			// Offset: GPIOx_BSRR  (atomic set/reset register)
.equ IDR_OFFSET,          0x10                			// Offset: GPIOx_IDR   (input data register)


// ===============================
// GPIOA register addresses (traffic lights)
// ===============================
.equ GPIOA_MODER,        (GPIOA_BASE + MODER_OFFSET)   	// Address of GPIOA_MODER (configure PA pin modes)
.equ GPIOA_ODR,          (GPIOA_BASE + ODR_OFFSET)     	// Address of GPIOA_ODR (write all PA outputs at once)
.equ GPIOA_BSRR,         (GPIOA_BASE + BSRR_OFFSET)    	// Address of GPIOA_BSRR (atomic set/reset of PA pins)


// ===============================
// GPIOC register addresses (car sensors)
// ===============================
.equ GPIOC_MODER,        (GPIOC_BASE + MODER_OFFSET)   	// Address of GPIOC_MODER (configure PC pin modes)
.equ GPIOC_IDR,          (GPIOC_BASE + IDR_OFFSET)     	// Address of GPIOC_IDR (read PC pin input levels)


// ===============================
// Friendly aliases (make intent obvious in code)
// ===============================
.equ TRAFFIC_LIGHTS_MDR,  GPIOA_MODER        			// Use this name when configuring traffic light pins as outputs
.equ TRAFFIC_LIGHTS_ODR,  GPIOA_ODR          			// Use this name when writing the traffic light states
.equ CAR_SENSORS_MDR,     GPIOC_MODER        			// Use this name when configuring sensor pins as inputs
.equ CAR_SENSORS_IDR,     GPIOC_IDR          			// Use this name when reading sensor pin levels


// ===============================
// MODER masks for traffic light pins on GPIOA
// (For output mode, MODER has 2 bits per pin = [2n+1:2n]. Output is 01.
//  We set only the low bit (2n) to 1; reset default ensures the high bit (2n+1) is 0.)
// ===============================
.equ MODER4_OUT,         (1U <<  8)          			// Set MODER[9:8] to 01 → PA4 = output
.equ MODER5_OUT,         (1U << 10)          			// Set MODER[11:10] to 01 → PA5 = output
.equ MODER6_OUT,         (1U << 12)          			// Set MODER[13:12] to 01 → PA6 = output
.equ MODER7_OUT,         (1U << 14)          			// Set MODER[15:14] to 01 → PA7 = output
.equ MODER8_OUT,         (1U << 16)          			// Set MODER[17:16] to 01 → PA8 = output
.equ MODER9_OUT,         (1U << 18)          			// Set MODER[19:18] to 01 → PA9 = output


// ===============================
// Bit masks for the traffic light LEDs on GPIOA (use with ODR/BSRR)
// ===============================
.equ NORTH_LED_GREEN,    (1U << 4)           			// PA4 controls North GREEN LED
.equ NORTH_LED_YELLOW,   (1U << 5)           			// PA5 controls North YELLOW LED
.equ NORTH_LED_RED,      (1U << 6)           			// PA6 controls North RED LED

.equ EAST_LED_GREEN,     (1U << 7)           			// PA7 controls East GREEN LED
.equ EAST_LED_YELLOW,    (1U << 8)           			// PA8 controls East YELLOW LED
.equ EAST_LED_RED,       (1U << 9)           			// PA9 controls East RED LED


// ===============================
// Bit masks for the car sensors on GPIOC (use with IDR)
// ===============================
.equ EAST_SENSOR,        (1U << 0)           			// PC0 reads the East approach sensor (1 = active, depending on wiring)
.equ NORTH_SENSOR,       (1U << 1)           			// PC1 reads the North approach sensor (1 = active, depending on wiring)


// ===============================
// State machine constants
// ===============================
.equ OUT,              0          						// Offset 0: LED output pattern, Byte offset to the OUT pattern within a state block
.equ WAIT,             4          						// Offset 4: wait time (ms), Byte offset to the WAIT time (ms) within a state block
.equ NEXT,             8          						// Offset 8: pointer to next states, Byte offset to the first “next state” pointer (then +4, +8, +12)
.equ SENSOR_PINS,      0x3        						// Mask PC1:PC0 → sensor bits (two sensor bits → values 0..3)
.equ go_north_address, go_north   						// Starting state address (first state in the table)


// ===============================
// Directives
// ===============================
	        .syntax unified                       		// Use the unified ARM/Thumb assembler syntax
	        .cpu cortex-m4                        		// Target CPU is Cortex-M4
	        .fpu softvfp                          		// Software floating point (not used, but harmless)
	        .thumb                                 		// Generate Thumb instructions


// ===============================
// Code section
// ===============================
	        .section .text
	        .global __main                        		// Export __main (program entry)
			.global systick_init
	        .global systick_delay
	        .global systick_delay_ms

// ===============================
// Traffic-light state table (finite state machine encoded as data)
// Each state is laid out as 4 words:
//   [0] OUT pattern (ODR bits for PA4..PA9; may also include bit0 = 1 per instructor’s style)
//   [1] WAIT time in milliseconds
//   [2] Next state if sensors = 00 (no cars East, no cars North)
//   [3] Next state if sensors = 01 (car East only)
//   [4] Next state if sensors = 10 (car North only)
//   [5] Next state if sensors = 11 (cars East AND North)
// You’ll pick the next state by reading PC0..PC1 into a 2-bit number and using it as an index.
// ===============================

go_north:
        .word 0x211                                        // OUT: turn ON North GREEN (PA4) + East RED (PA9)
                                                           // 0x211 = 0x200 (PA9) + 0x010 (PA4) + 0x001 (bit0)
        .word 3000                                         // WAIT: stay in this state for 3000 ms (3 seconds)
        .word go_north, wait_north, go_north, wait_north   // NEXT: [00]=go_north, [01]=wait_north, [10]=go_north, [11]=wait_north

wait_north:
        .word 0x221                                        // OUT: turn ON North YELLOW (PA5) + East RED (PA9)
        .word 500                                          // WAIT: 500 ms (0.5 seconds)
        .word go_east, go_east, go_east, go_east           // NEXT: any sensor combo → go_east

go_east:
        .word 0x0C1                                        // OUT: turn ON North RED (PA6) + East GREEN (PA7)
        .word 3000                                         // WAIT: 3000 ms
        .word go_east, go_east, wait_east, wait_east       // NEXT: [00]=go_east, [01]=go_east, [10]=wait_east, [11]=wait_east

wait_east:
        .word 0x141                                        // OUT: turn ON North RED (PA6) + East YELLOW (PA8)
        .word 500                                          // WAIT: 500 ms
        .word go_north, go_north, go_north, go_north       // NEXT: any sensor combo → go_north


// ===============================
// __main
// Program entry point.
// - Initialises SysTick timer
// - Enables GPIOA (traffic lights) and GPIOC (sensors)
// - Configures PA4..PA9 as outputs for LEDs
// - Sets r4 = pointer to current state (start at go_north)
// - Runs the infinite state machine loop
// ===============================
__main:
		bl  systick_init                // Call systick_init (set up SysTick timer for delays)

        /* Enable clock access to GPIOA (traffic lights) */
        ldr r0, =RCC_AHB1ENR            // Load address of RCC_AHB1ENR into r0
        ldr r1, [r0]                    // Read current AHB1ENR value into r1
        orr r1, r1, #GPIOA_EN           // Set bit 0 in r1 (enable GPIOA clock)
        str r1, [r0]                    // Write updated value back to AHB1ENR

        /* Set PA4..PA9 as outputs (traffic light pins) */
        ldr r0, =TRAFFIC_LIGHTS_MDR     // Load address of GPIOA_MODER into r0
        ldr r1, [r0]                    // Read current MODER value into r1
        orr r1, r1, #MODER4_OUT         // Set MODER bits for PA4 to output (MODER[9:8] = 01)
        orr r1, r1, #MODER5_OUT         // Set MODER bits for PA5 to output (MODER[11:10] = 01)
        orr r1, r1, #MODER6_OUT         // Set MODER bits for PA6 to output (MODER[13:12] = 01)
        orr r1, r1, #MODER7_OUT         // Set MODER bits for PA7 to output (MODER[15:14] = 01)
        orr r1, r1, #MODER8_OUT         // Set MODER bits for PA8 to output (MODER[17:16] = 01)
        orr r1, r1, #MODER9_OUT         // Set MODER bits for PA9 to output (MODER[19:18] = 01)
        str r1, [r0]                    // Write updated MODER back to GPIOA

        /* Enable clock access to GPIOC (sensors) */
        ldr r0, =RCC_AHB1ENR            // Load address of RCC_AHB1ENR into r0
        ldr r1, [r0]                    // Read current value into r1
        orr r1, r1, #GPIOC_EN           // Set bit 2 (enable GPIOC clock)
        str r1, [r0]                    // Write back to RCC

        /* Cache handy pointers in registers */
        ldr r4, =go_north_address       // r4 = address of current state (start at go_north)
        ldr r5, =CAR_SENSORS_IDR        // r5 = address of GPIOC_IDR (read sensors PC1:PC0)
        ldr r6, =TRAFFIC_LIGHTS_ODR     // r6 = address of GPIOA_ODR (write traffic light pattern)

// ===============================
// state_machine
// Infinite loop that drives the lights
// 1) Output the state’s LED pattern
// 2) Delay for the state’s WAIT time
// 3) Read sensors PC1:PC0 and pick the next state
// 4) Repeat forever
// ===============================
state_machine:
		/* 1) Output pattern for this state */
        ldr r0, [r4, #OUT]              // Load OUT word from current state into r0
        str r0, [r6]                    // Write r0 to GPIOA_ODR (drive PA4..PA9 LEDs)

        /* 2) Wait for this state's duration (milliseconds) */
        ldr r0, [r4, #WAIT]             // Load WAIT word (ms) from current state into r0
        bl  systick_delay_ms            // Delay r0 milliseconds using SysTick

        /* 3) Read sensors and choose next state */
        ldr r0, [r5]                    // Read GPIOC_IDR (all PC inputs) into r0
        and r0, r0, #SENSOR_PINS        // Keep only PC1:PC0 (sensor bits) in r0 (values 0..3)
        lsl r0, r0, #2                  // Multiply by 4 (word offset per entry) → 0,4,8,12
        add r0, r0, #NEXT               // Add base offset of next-state table inside state block (NEXT = 8)
        ldr r4, [r4, r0]                // Load next state's address from [current_state + computed offset] into r4

        b   state_machine               // Loop forever (process next state)




			.align
			.end						// Required to end program

