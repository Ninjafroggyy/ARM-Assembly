


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
			ldr	r0, =0xBABEFACE		// Load 32 bit value
			ldr r1, =0xDEADBEEF		// Load 32 bit value

			eor	r0, r0, r1			// Exclusive OR store in r0
			eor	r1, r0, r1			// Exclusive OR store in r1
			eor r0, r0, r1			// Exclusive OR store in r0
stop:
			b stop					// Branch back to stop instruction (loop)


			.align
			.end					// Required to end program
