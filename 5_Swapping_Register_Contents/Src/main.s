
// Renaming registers
val1	.req	r1		// Rename register 1 as val1
val2	.req	r2		// Rename register 2 as val2
sum		.req	r3		// Rename register 3 as sum


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
			b stop


			.align
			.end					// Required to end program
