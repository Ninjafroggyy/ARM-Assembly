

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
			mov r0, #0x11				// Adding hexadecimal 17 into register 0
			lsl r1, r0, #1				// Shift 1 bit left = 17 x 2^1 = 34
			lsl	r2, r1, #1				// Shift 1 bit left = 34 x 2^1 = 68


stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program
