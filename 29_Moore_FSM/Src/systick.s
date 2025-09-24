

// ===============================
// SysTick (core timer)
// ===============================
.equ NVIC_ST_CTRL_R,    0xE000E010                       // SysTick Control and Status register
.equ NVIC_ST_RELOAD_R,  0xE000E014                       // SysTick Reload Value register
.equ NVIC_ST_CURRENT_R, 0xE000E018                       // SysTick Current Value register

// SysTick constants
.equ SYSTICK_24BIT_MAX, 0x00FFFFFF                       // Maximum 24-bit reload value
.equ DELAY1MS,			16000							 // ≈1  ms worth of core ticks @ 16 MHz (used by systick_delay_ms)

// SysTick CTRL bitmasks
.equ ST_CTRL_EN,        (1 << 0)                         // CTRL: enable SysTick counter
.equ ST_CTRL_CLKSRC,    (1 << 2)                         // CTRL: clock source = processor clock
.equ ST_CTRL_COUNTFLG,  (1 << 16)                        // CTRL: COUNTFLAG (set when timer counts to 0)



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
	        .global systick_init
	        .global systick_delay
	        .global systick_delay_ms


// ------------------------------------------------------------
// void systick_init(void)
// Configure SysTick to use the core clock and be ready for delays.
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// void systick_delay(uint32_t ticks)
// r0 = number of ticks to wait (reload value = ticks - 1)
// Busy-waits until COUNTFLAG sets once.
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// void systick_delay_ms(uint32_t ms)
// r0 = number of milliseconds to wait
// Uses systick_delay(DELAY1MS) in a loop.
// ------------------------------------------------------------
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


			.align
			.end											// Required to end program
