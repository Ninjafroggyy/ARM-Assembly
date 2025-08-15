
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
			ldr r0, =A				// Point r0 to memory location A
			mov r1, #5				// Put 5 into registry 1
			str r1, [r0]			// Store content of r1 (5) into the memory address (A) that r0 is pointing at

			ldr r0, =B				// Point r0 to memory location B
			mov r1, #4				// Put 4 into registry 1
			str r1, [r0]			// Store content of r1 (4) into the memory address (B) that r0 is pointing at

			ldr r0, =C				// Point r0 to memory location C
			mov r1, #200			// Put 200 into registry 1
			str r1, [r0]			// Store content of r1 (5) into the memory address (C) that r0 is pointing at
stop:
			b stop					// Branch back to stop instruction (loop)


			.section .data			// Stores to RAM location

A:			.space		4			// Allocate 4 bytes of memory filled with zeroes
B:			.space		4			// Allocate 4 bytes of memory filled with zeroes
C:			.space		4			// Allocate 4 bytes of memory filled with zeroes


			.align
			.end					// Required to end program
