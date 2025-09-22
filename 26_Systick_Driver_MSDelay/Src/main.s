

// ===============================
// RCC (Reset and Clock Control)
// ===============================
.equ RCC_BASE,          0x40023800                       // Base address of RCC peripheral block
.equ AHB1ENR_OFFSET,    0x30                             // Offset: AHB1 peripheral clock enable register
.equ RCC_AHB1ENR,      (RCC_BASE + AHB1ENR_OFFSET)       // Address of RCC_AHB1ENR (enables GPIO clocks)

// RCC bitmasks
.equ GPIOA_EN,         (1 << 0)                         // Bit 0 in RCC_AHB1ENR → enable GPIOA clock

// ===============================
// GPIOA (LED on PA5)
// ===============================
.equ GPIOA_BASE,        0x40020000                       // Base address of GPIOA peripheral

// GPIOA register addresses
.equ MODER_OFFSET,      0x00                             // Offset: GPIO port mode register (MODER)
.equ GPIOA_MODER,      (GPIOA_BASE + MODER_OFFSET)       // Address of GPIOA_MODER (pin mode config)

.equ BSRR_OFFSET,       0x18                             // Offset: GPIO port bit set/reset register (BSRR)
.equ GPIOA_BSRR,       (GPIOA_BASE + BSRR_OFFSET)        // Address of GPIOA_BSRR (atomic bit set/reset)

// GPIOA bitmasks
.equ MODER5_OUT,       (1 << 10)                         // MODER: configure PA5 as output (MODER[11:10] = 01)
.equ BSRR_5_SET, 	   (1 << 5)							 // BSRR register: set PA5 high (LED on)
.equ BSRR_5_RESET, 	   (1 << 21)						 // BSRR register: reset PA5 low (LED off)

// ===============================
// SysTick (core timer)
// ===============================
.equ NVIC_ST_CTRL_R,    0xE000E010                       // SysTick Control and Status register
.equ NVIC_ST_RELOAD_R,  0xE000E014                       // SysTick Reload Value register
.equ NVIC_ST_CURRENT_R, 0xE000E018                       // SysTick Current Value register

// SysTick constants
.equ SYSTICK_24BIT_MAX, 0x00FFFFFF                       // Maximum 24-bit reload value

// SysTick CTRL bitmasks
.equ ST_CTRL_EN,        (1 << 0)                         // CTRL: enable SysTick counter
.equ ST_CTRL_CLKSRC,    (1 << 2)                         // CTRL: clock source = processor clock
.equ ST_CTRL_COUNTFLG,  (1 << 16)                        // CTRL: COUNTFLAG (set when timer counts to 0)

.equ DELAY1MS,			16000							 // ~1 ms worth of core ticks @ 16 MHz (used by systick_delay_ms)


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
			bl gpioa_init                                   // Branch with link: configure GPIOA and cache BSRR address
	        bl systick_init                                 // Branch with link: configure SysTick timer

loop:
	        bl blink                                        // Call blink (toggle LED with SysTick delays)
	        b  loop                                         // Branch back to loop (repeat forever)


gpioa_init:
	        /* Enable clock access to GPIOA */
	        ldr r0, =RCC_AHB1ENR                            // Load address of RCC_AHB1ENR into r0
	        ldr r1, [r0]                                    // Load 32-bit value from [r0] into r1 (read RCC_AHB1ENR)
	        orr r1, r1, #GPIOA_EN                           // Bitwise OR r1 with GPIOA_EN; store result in r1 (set GPIOA clock enable)
	        str r1, [r0]                                    // Store r1 back to [r0] (write updated enable)

	        /* Configure PA5 as output */
	        ldr r0, =GPIOA_MODER                            // Load address of GPIOA_MODER into r0
	        ldr r1, [r0]                                    // Load 32-bit value from [r0] into r1 (read current MODER)
	        orr r1, r1, #MODER5_OUT                         // OR r1 with MODER5_OUT; store in r1 (set PA5 mode bits to 01)
	        str r1, [r0]                                    // Store r1 back to [r0] (apply PA5 output mode)

	        /* Cache GPIOA_BSRR address and clear r1 */
	        mov r1, #0                                      // Move immediate 0 into r1
	        ldr r2, =GPIOA_BSRR                             // Load address of GPIOA_BSRR into r2 (used by blink)

systick_init:
	        /* Disable SysTick before configuration */
	        ldr r1, =NVIC_ST_CTRL_R                         // Load address of SysTick CTRL into r1
	        mov r0, #0                                      // Move 0 into r0
	        str r0, [r1]                                    // Store r0 to [r1] (disable SysTick, clear CTRL)

	        /* Load maximum value into SysTick RELOAD */
	        ldr r1, =NVIC_ST_RELOAD_R                       // Load address of SysTick RELOAD into r1
	        ldr r0, =SYSTICK_24BIT_MAX                      // Load 24-bit maximum into r0
	        str r0, [r1]                                    // Store r0 to [r1] (set reload value)

	        /* Clear SysTick CURRENT by writing any value */
	        ldr r1, =NVIC_ST_CURRENT_R                      // Load address of SysTick CURRENT into r1
	        mov r0, #0                                      // Move 0 into r0
	        str r0, [r1]                                    // Store r0 to [r1] (clears current count and COUNTFLAG)

	        /* Select processor clock and enable SysTick */
	        ldr r0, =NVIC_ST_CTRL_R                         // Load address of SysTick CTRL into r0
	        ldr r1, [r0]                                    // Read current CTRL into r1
	        orr r1, r1, #ST_CTRL_CLKSRC                     // OR r1 with CLKSRC; store in r1 (select core clock)
	        orr r1, r1, #ST_CTRL_EN                         // OR r1 with EN; store in r1 (enable SysTick)
	        str r1, [r0]                                    // Store r1 back to [r0] (write CTRL)

	        bx  lr                                          // Return from systick_init

systick_delay:
	        /* Program a new reload value (r0 = desired ticks) */
	        ldr r1, =NVIC_ST_RELOAD_R                       // Load address of SysTick RELOAD into r1
	        sub r0, #1                                      // Subtract 1 from r0 (RELOAD is N-1)
	        str r0, [r1]                                    // Store r0 to [r1] (apply reload value)

delay_loop:
	        /* Poll COUNTFLAG until it sets (timer reached 0) */
	        ldr r1, =NVIC_ST_CTRL_R                         // Load address of SysTick CTRL into r1
	        ldr r3, [r1]                                    // Load CTRL into r3
	        ands r3, r3, #ST_CTRL_COUNTFLG                  // ANDS r3 with COUNTFLAG (update flags) — Z=1 means flag is 0
	        beq delay_loop                                  // If Z==1 (flag not set), branch to delay_loop (keep waiting)

	        bx  lr                                          // Return from systick_delay

systick_delay_ms:
	        push {r4, lr}                                   // Save r4 and return address on stack
	        movs r4, r0                                     // r4 = r0 (number of milliseconds); updates flags
	        beq  complete                                   // if r4 == 0, skip loop and return

ms_loop:
	        ldr  r0, =DELAY1MS                              // r0 = 16000 (≈1 ms @16 MHz)
	        bl   systick_delay                              // busy-wait 1 ms (using SysTick)
	        subs r4, r4, #1                                 // r4 = r4 - 1; updates flags
	        bhi  ms_loop                                    // if r4 > 0 (unsigned), loop again

complete:
	        pop  {r4, lr}                                   // Restore r4 and return address
	        bx   lr                                         // return

blink:
	        /* LED on (write full ODR value 0x20) */
	        mov r1, #BSRR_5_SET                             // Move BSRR_5_SET immediate into r1 (0x20)
	        str r1, [r2]                                    // Store to GPIOA_BSRR → sets PA5

	        /* Delay ~N ticks using SysTick */
	        ldr r0, =500	                                // r0 = 500 (milliseconds)
	        bl  systick_delay_ms                            // Call systick_delay_ms

	        /* LED off (write full ODR value 0x1) */
	        mov r1, #BSRR_5_RESET                           // Move BSRR_5_RESET immediate into r1 (0x1)
	        str r1, [r2]                                    // Store r1 to [r2] (write to GPIOA_BSRR → resets PA5)

	        /* Delay again */
	        ldr r0, =500	                                // r0 = 500 (milliseconds)
	        bl  systick_delay_ms                            // Call systick_delay_ms

	        b   blink                                       // Branch back to blink (repeat forever)

			.align
			.end											// Required to end program

