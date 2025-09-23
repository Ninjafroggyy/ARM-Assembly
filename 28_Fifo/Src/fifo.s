

					.section .data

put_pointer:    .space 4                                 // current write pointer (address within fifo..fifo+SIZE)
get_pointer:    .space 4                                 // current read  pointer (address within fifo..fifo+SIZE)

.equ SIZE, 8                                             // ring size (power of two)

fifo:           .space SIZE                              // storage for FIFO (SIZE bytes)

// ===============================
// Symbolic addresses
// ===============================
.equ fifo_address,        fifo                			// Start address of fifo buffer
.equ fifo_end_address,    fifo + SIZE         			// Address just past the last byte in fifo
.equ put_pointer_address, put_pointer         			// Address in memory where put_pointer is stored
.equ get_pointer_address, get_pointer         			// Address in memory where get_pointer is stored


// ===============================
// Directives
// ===============================
			.syntax unified
			.cpu cortex-m4
			.fpu softvfp
			.thumb

// ===============================
// Code
// ===============================
			.section .text
			.global fifo_init
			.global fifo_put
			.global fifo_get
			.global fifo_size


// ===============================
// fifo_init()
// ===============================
// Initialise FIFO: set both put_pointer and get_pointer to the start of the buffer
fifo_init:
			/* Set put_pointer and get_pointer to fifo_address */
			ldr r0, =fifo_address            // Load start address of fifo into r0
	        ldr r1, =put_pointer_address     // Load address of put_pointer variable into r1
	        str r0, [r1]                     // Store fifo start address into put_pointer

	        ldr r1, =get_pointer_address     // Load address of get_pointer variable into r1
	        str r0, [r1]                     // Store fifo start address into get_pointer

	        bx  lr                           // Return

// ===============================
// fifo_put(r0 = byte)
// ===============================
// Add one byte to the fifo (value passed in r0).
// If fifo is full, nothing is written and r0 is returned as 0.
fifo_put:
			ldr r1, =put_pointer_address     // r1 = address of put_pointer variable
	        ldr r2, [r1]                     // r2 = current put_pointer (where to write)

	        add r3, r2, #1                   // r3 = next put pointer = current + 1
	        ldr r12, =fifo_end_address       // r12 = end address of fifo
	        cmp r3, r12                      // Compare next put pointer with end address
	        bne _proceed_with_put            // If not at end, continue
	        ldr r3, =fifo_address            // If at end, wrap around → reset to start of fifo

_proceed_with_put:
			ldr r12, =get_pointer_address    // r12 = address of get_pointer variable
	        ldr r12, [r12]                   // r12 = current get_pointer
	        cmp r3, r12                      // Compare next put with get → full?
	        bne _not_full                    // If not equal, there is space

	        mov r0, #0                       // If equal, fifo is full → return 0 in r0
	        bx  lr                           // Return

_not_full:
			strb r0, [r2]                    // Store the low 8 bits of r0 (the byte) into fifo at [put_pointer]
	        str  r3, [r1]                    // Update put_pointer = next put position
	        mov  r0, #0                      // Return 0 (this code does not distinguish success/fail)
	        bx   lr                          // Return

// ===============================
// fifo_get(r0 = destination address)
// ===============================
// Remove one byte from fifo and store it at memory[r0].
// If fifo is empty, no value is written and r0 returns 0.
fifo_get:
			push {r4, r5, lr}                // Save r4, r5, and link register (return address)

	        ldr r1, =put_pointer_address     // r1 = address of put_pointer variable
	        ldr r1, [r1]                     // r1 = current put_pointer
	        ldr r2, =get_pointer_address     // r2 = address of get_pointer variable
	        ldr r3, [r2]                     // r3 = current get_pointer

	        cmp r1, r3                       // Compare put and get pointers
	        bne _fifo_not_empty              // If different, fifo has data
	        mov r0, #0                       // If equal, fifo is empty → return 0
	        b   _cleanup

_fifo_not_empty:
			ldrsb r4, [r3]                   // Load signed byte from fifo at [get_pointer] into r4
	        strb  r4, [r0]                   // Store that byte into memory at [r0] (caller’s destination)

	        add   r3, r3, #1                 // Increment get_pointer
	        ldr   r5, =fifo_end_address      // r5 = fifo end address
	        cmp   r3, r5                     // If get_pointer == end, wrap
	        bne   _update_get_pointer
	        ldr   r3, =fifo_address          // Reset get_pointer to start of fifo

_update_get_pointer:
        	str r3, [r2]                     // Write updated get_pointer back

_cleanup:
			pop {r4, r5, lr}                 // Restore r4, r5, and return address
        	bx  lr                           // Return

// ===============================
// fifo_size()
// ===============================
// Return the number of bytes currently stored in the fifo.
// Uses (put - get) & (SIZE-1) for circular wrap calculation.
fifo_size:
			ldr r1, =put_pointer_address     // r1 = address of put_pointer
	        ldr r1, [r1]                     // r1 = current put_pointer
	        ldr r2, =get_pointer_address     // r2 = address of get_pointer
	        ldr r3, [r2]                     // r3 = current get_pointer
	        sub r0, r1, r3                   // r0 = put_pointer - get_pointer
	        and r0, r0, #(SIZE - 1)          // Mask with SIZE-1 to handle wrap (valid range 0..SIZE-1)
	        bx  lr                           // Return


			.align
			.end
