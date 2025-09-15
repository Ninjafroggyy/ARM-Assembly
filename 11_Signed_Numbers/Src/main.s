
			.section .data

SIGN_DATA:	.byte +13, -10, +9, +14, -18, -9, +12, -19, +16		// Array of numbers



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
			ldr r0, =SIGN_DATA			// Load address of SIGN_DATA into r0
			mov r3, #9					// Count
			mov r2, #0					// Sum

loop:
			ldrsb r1, [r0]				// Load assigned byte (sb) from memory address found in r0 into r1
			add r2, r2, r1				// Add value in r0 to value in r1, store in r2
			add r0, r0, #1				// Adding one byte to r0 to get the next number in the array
			subs r3, r3, #1				// Subtract one from counter and update conditional flags

			bne loop					// Branch to top of loop if the counter is not 0


stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program
