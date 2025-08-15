
// Directives
			.syntax unified
			.cpu cortex-m4
			.fpu softvfp
			.thumb

// Code Section
			.section .text

// Global calls for external files to call
			.global __main
			.global num				// Makes C variable a global variable
			.global Adder			// Makes C function a global function

__main:
			ldr r1, =num			// Load the memory address of num into register 1
			mov r0, #100			// Put 100 into register 0
			str r0, [r1]			// Store the value in r0 (100) into the address register 1 is pointing at

			bl Adder				// Branch to the Adder function

stop:
			b stop					// Branch back to stop instruction (loop)


			.align
			.end					// Required to end program
