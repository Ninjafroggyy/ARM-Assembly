
// ===============================
// Data: consumer array to read FIFO bytes into
// ===============================
        .data

consumer_arr:  .space 8                 // Reserve 8 bytes to store values read from the FIFO

// Handy byte addresses inside consumer_arr (index 0..7)
.equ arr_index0, consumer_arr           // Address of consumer_arr[0]
.equ arr_index1, consumer_arr + 1       // Address of consumer_arr[1]
.equ arr_index2, consumer_arr + 2       // Address of consumer_arr[2]
.equ arr_index3, consumer_arr + 3       // Address of consumer_arr[3]
.equ arr_index4, consumer_arr + 4       // Address of consumer_arr[4]
.equ arr_index5, consumer_arr + 5       // Address of consumer_arr[5]
.equ arr_index6, consumer_arr + 6       // Address of consumer_arr[6]
.equ arr_index7, consumer_arr + 7       // Address of consumer_arr[7]


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
			.global __main

__main:
			bl  fifo_init                    // Call fifo_init: set put_pointer and get_pointer to start of FIFO

loop:
	        // ---- Write (produce) 8 bytes into the FIFO ----
			mov r0, #1                      // Move the value 1 into r0 (this is the byte we want to store)
	        bl  fifo_put                    // Call fifo_put: it will store the byte in r0 into the FIFO (if not full)

	        mov r0, #2                      // Move the value 2 into r0
	        bl  fifo_put                    // Store 2 into the FIFO

	        mov r0, #3                      // Move the value 3 into r0
	        bl  fifo_put                    // Store 3 into the FIFO

	        mov r0, #4                      // Move the value 4 into r0
	        bl  fifo_put                    // Store 4 into the FIFO

	        mov r0, #5                      // Move the value 5 into r0
	        bl  fifo_put                    // Store 5 into the FIFO

	        mov r0, #6                      // Move the value 6 into r0
	        bl  fifo_put                    // Store 6 into the FIFO

	        mov r0, #7                      // Move the value 7 into r0
	        bl  fifo_put                    // Store 7 into the FIFO

	        mov r0, #8                      // Move the value 8 into r0
	        bl  fifo_put                    // Store 8 into the FIFO (with SIZE=8, this extra write will be rejected)

	        // ---- (Optional) Check fill level of FIFO ----
	        bl  fifo_size                   // Call fifo_size: returns current number of stored bytes in r0 (0..7)

	        // ---- Read (consume) up to 8 bytes from the FIFO into consumer_arr[0..7] ----
	        ldr r0, =arr_index0             // Load the address of consumer_arr[0] into r0 (destination pointer)
	        bl  fifo_get                    // Call fifo_get: if data available, writes 1 byte to [r0]

	        ldr r0, =arr_index1             // Load address of consumer_arr[1] into r0
	        bl  fifo_get                    // Read next byte into [consumer_arr+1] (if data present)

	        ldr r0, =arr_index2             // Load address of consumer_arr[2] into r0
	        bl  fifo_get                    // Read next byte into [consumer_arr+2]

	        ldr r0, =arr_index3             // Load address of consumer_arr[3] into r0
	        bl  fifo_get                    // Read next byte into [consumer_arr+3]

	        ldr r0, =arr_index4             // Load address of consumer_arr[4] into r0
	        bl  fifo_get                    // Read next byte into [consumer_arr+4]

	        ldr r0, =arr_index5             // Load address of consumer_arr[5] into r0
	        bl  fifo_get                    // Read next byte into [consumer_arr+5]

	        ldr r0, =arr_index6             // Load address of consumer_arr[6] into r0
	        bl  fifo_get                    // Read next byte into [consumer_arr+6]

	        ldr r0, =arr_index7             // Load address of consumer_arr[7] into r0
	        bl  fifo_get                    // Read next byte into [consumer_arr+7] (FIFO will now be empty; this call does nothing)

	        b   loop                        // Branch back to 'loop' label (repeat the produce/consume sequence forever)





			.align
			.end
