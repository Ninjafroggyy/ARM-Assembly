
// Directives
			.syntax unified
			.cpu cortex-m4
			.fpu softvfp
			.thumb

// Code Section
			.section .text
			.global num_func

num_func:
			mov r0, #121			// Put 121 into register 0
			bx lr					// Return from subroutine

			.align
			.end					// Required to end program
