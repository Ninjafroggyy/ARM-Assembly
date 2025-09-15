
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
			ldr r0, =60					// Load the constant value 60 into r0 (assembler creates a literal pool entry)
			mov r1, #10					// Put 10 into r1
			mov r2, #0					// Put 0 into r2 (counter)

loop:
			cmp r0, r1					// value in r0 with r1

			blo stop					// Branch to stop if r0 is lower than r1
			sub r0, r0, r1				// Subtract r1 (10) from r0 and place the result into r0
			add r2, r2, #1				// Add 1 to the value in r2 (counter)

			b loop						// Branch to loop

stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program

