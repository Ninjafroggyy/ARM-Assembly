

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
			mov r5, #45			// Put the number 45 into register 5
			mov r3, #45			// Put the number 45 into register 3

			add r6, r5, r3		// Add the numbers in register 3 and 5 together and place into register 6

stop:
			b stop				// Branch back to stop instruction (loop)

			.align
			.end				// Required to end program
