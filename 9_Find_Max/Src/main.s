

// Variable names for registers
count		.req	r0
max			.req	r1
pointer		.req	r2
next		.req	r3

// Array of numbers
mydata:		.word	69, 87, 86, 45, 75


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
			mov count, #5				// Placed count at 5 to match the array amount
			mov max, #0					// Number 0 placed into r1

again:
			ldr pointer, =mydata		// Load memory address of mydata into r2
			ldr next, [pointer]			// Load value at memory address found in r2 into r3

			cmp max, next				// Compare max with r3 and update conditional flags

			bhs continue				// Branch to continue if max is equal or greater than r3 value

			mov max, next				// Move value of next into max

continue:
			add pointer, pointer, #4	// Add 4 bytes to pointer and store results in pointer
			subs count, count, #1		// Subtract 1 from count and update conditional flags

			bne again					// Branch if results is not equal to zero

stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program




