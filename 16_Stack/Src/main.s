
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
			ldr r3, =0xDEADBEEF			// Load constant 0xDEADBEEF into r3 (via literal pool, since it won't fit in an immediate)
			ldr r4, =0xBABEFACE			// Load constant 0xBABEFACE into r4

			push {r3}					// Push the content in r3 onto the stack
			push {r4}					// Push the content in r4 onto the stack

			pop {r5}					// Pop top of stack into r5
			pop {r6}					// Pop top of stack into r6


stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program

