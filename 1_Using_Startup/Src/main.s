

// ===============================
// Directives
// ===============================
	        .syntax unified                 // Use Unified Assembler Syntax (ARM/Thumb)
	        .cpu cortex-m4                  // Target CPU core is Cortex-M4
	        .fpu softvfp                    // Use software floating point (not used here, but set for project)
	        .thumb                          // Generate Thumb instruction set

// ===============================
// Code section
// ===============================
	        .section .text

	        .global __main                  // Export __main so the linker can find the program entry


__main:
			mov r5, #45			// Put the number 45 into register 5
			mov r3, #45			// Put the number 45 into register 3

			add r6, r5, r3		// Add the numbers in register 3 and 5 together and place into register 6

stop:
			b stop				// Branch back to stop instruction (loop)

			.align
			.end				// Required to end program
