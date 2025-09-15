
// (A + 8B + 7C - 27) / 4
// Let A = 25, B = 19, C = 99

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
			mov r0, #25					// Put A (25) into r0
			mov r1, #19					// Put B (19) into r1

			add r0, r0, r1, lsl #3		// Add 8B (r1, lsl, #3 = (B × 2^3) = 19^3) to A (25) and store in r0

			mov r1, #99					// Put C (99) into r1
			mov r2, #7					// Put 7 into r2

			mla r0, r1, r2, r0			// Multiplies values in r1 and r2 (7C) and adds the value in r0 and places result in r0
			sub r0, r0, #27				// Subtract 27 from result in r0

			mov r0, r0, asr #2			// Divide the total value in r0 by 4

stop:
			b stop						// Branch back to stop instruction (loop)


			.align
			.end						// Required to end program
