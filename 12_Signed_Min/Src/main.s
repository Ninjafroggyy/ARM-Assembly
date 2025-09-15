
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
			ldr r0, =SIGN_DATA			// Load the address of SIGN_DATA into r0
			mov r3, #8					// Making r3 keep count of the array position

			ldrsb r2, [r0]				// Load a signed byte from memory address found in r0 (the array) into r2
			add r0, r0, #1				// Add one to r0 to get to the next value in the array

loop:
			ldrsb r1, [r0]				// Load a signed byte from memory address found in r0 (the array) into r1
			cmp r1, r2					// Compare the value in r1 with r2

			bge next					// Branch to next if r1 is greater that or equal to r2
			mov r2, r1					// Move the value from r1 into r2

next:
			add r0, r0, #1				// Add one to r0 to get to the next value in the array
			subs r3, r3, #1				// Update conditional flag if counter = 0

			bne loop					// Branch to loop if result is not equal to 0

stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program
