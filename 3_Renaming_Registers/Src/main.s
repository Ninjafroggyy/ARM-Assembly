
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
			mov val1, #60			// Put the number 60 into register 1 using the val1 name
			mov val2, #40			// Put the number 40 into register 2 using the val2 name

			add sum, val1, val2		// Adding val1 and val2 together and placing value into register 3 using the sum name

stop:
			b stop					// Branch back to stop instruction (loop)

			.align
			.end					// Required to end program
