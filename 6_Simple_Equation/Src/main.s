
// Variables
.equ Q, 2
.equ R, 4
.equ S, 5

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
			mov r1, #Q				// Put the variable Q into register 1 - As Q is a number it requires # before it
			mov r2, #R				// Put the variable R into register 2 - As R is a number it requires # before it
			mov r3, #S				// Put the variable S into register 3 - As S is a number it requires # before it

			add r0, r1, r2			// Add values in r1 and r2 together and put into register 0
			add r0, r0, r3			// Add values in r0 and r3 together and put into register 0

stop:
			b stop					// Branch back to stop instruction (loop)


			.align
			.end					// Required to end program
