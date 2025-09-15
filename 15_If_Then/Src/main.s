
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
			mov r6, #4					// Put 4 into r6
			mov r7, #1					// Put 1 in r7

loop:
			cmp r6, #0					// Compare r6 with 0

			ittt GT						// If r6 is greater than 0 then execute the next 3 instructions
			mulgt r7, r6, r7			// Multiply r6 with r7 if r6 is greater than 0 and place value in r7
			subgt r6, r6, #1			// Subtract 1 from r6 if r6 is greater than 0 and place value in r6

			bgt loop					// Branch to loop if r6 is greater than 0


stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program

