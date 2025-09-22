// ===============================
// RCC (Reset & Clock Control)
// ===============================
.equ RCC_BASE,         0x40023800                       // Base address of RCC peripheral block

.equ AHB1ENR_OFFSET,   0x30                             // Offset: AHB1 peripheral clock enable register
.equ RCC_AHB1ENR,     (RCC_BASE + AHB1ENR_OFFSET)       // Address of RCC_AHB1ENR (enable GPIOA clock, etc.)

.equ APB1ENR_OFFSET,   0x40                             // Offset: APB1 peripheral clock enable register
.equ RCC_APB1ENR,     (RCC_BASE + APB1ENR_OFFSET)       // Address of RCC_APB1ENR (enable USART2 clock, etc.)

// Clock enable bitmasks
.equ GPIOA_EN,        (1 << 0)                          // Bit mask: RCC_AHB1ENR bit 0 → enable clock for GPIOA
.equ USART2_EN,       (1 << 17)                         // Bit mask: RCC_APB1ENR bit 17 → enable clock for USART2

// ===============================
// GPIO common offsets (for all GPIO ports)
// ===============================
.equ MODER_OFFSET,     0x00                             // Offset: GPIO port mode register (MODER)
.equ AFRL_OFFSET,      0x20                             // Offset: GPIO alternate function low register (pins 0..7)

// ===============================
// GPIOA (USART2 TX on PA2)
// ===============================
.equ GPIOA_BASE,       0x40020000                       // Base address of GPIOA
.equ GPIOA_MODER,     (GPIOA_BASE + MODER_OFFSET)       // Address of GPIOA_MODER (configures pin modes)
.equ GPIOA_AFRL,      (GPIOA_BASE + AFRL_OFFSET)        // Address of GPIOA_AFRL (AF selection for PA0..PA7)
.equ MODER2_ALT_SLT,  (1 << 5)                          // Value to OR into MODER to set PA2 mode to AF (bit 5 = 1, bit 4 = 0)
.equ MODER3_ALT_SLT,  (1 << 7)                          //
.equ PIN2_AF7_SLT,    0x700                             // Value to OR into AFRL to select AF7 for PA2 (bits 11:8 = 0111)
.equ PIN3_AF7_SLT,    0x7000                            // Value to OR into AFRL to select AF7 for PA3

// ===============================
// USART2 (on APB1, base 0x4000 4400)
// ===============================
.equ UART2_BASE,       0x40004400                       // Base address of USART2

// Register offsets (USART block)
.equ SR_OFFSET,        0x00                             // Offset: Status register (SR)
.equ DR_OFFSET,        0x04                             // Offset: Data register (DR)
.equ BRR_OFFSET,       0x08                             // Offset: Baud rate register (BRR)
.equ CR1_OFFSET,       0x0C                             // Offset: Control register 1 (CR1)
.equ CR2_OFFSET,       0x10                             // Offset: Control register 2 (CR2)
.equ CR3_OFFSET,       0x14                             // Offset: Control register 3 (CR3)

// Full register addresses
.equ UART2_SR,        (UART2_BASE + SR_OFFSET)          // Address of USART2 status register
.equ UART2_DR,        (UART2_BASE + DR_OFFSET)          // Address of USART2 data register (write TX / read RX)
.equ UART2_BRR,       (UART2_BASE + BRR_OFFSET)         // Address of USART2 baud rate register
.equ UART2_CR1,       (UART2_BASE + CR1_OFFSET)         // Address of USART2 control register 1
.equ UART2_CR2,       (UART2_BASE + CR2_OFFSET)         // Address of USART2 control register 2
.equ UART2_CR3,       (UART2_BASE + CR3_OFFSET)         // Address of USART2 control register 3

// Config values (for 16 MHz clock → 9600 baud)
.equ BRR_CNF,         0x0683                            // BRR = 0x0683 → mantissa 0x68, fraction 0x3 (≈9600 @ 16 MHz)

// CR1/2/3 setup values
.equ CR1_CNF,         0x0008                            // CR1: TE=1 (enable transmitter), 8-bit data, UE=0 for now
.equ CR2_CNF,         0x0000                            // CR2: 1 stop bit
.equ CR3_CNF,         0x0000                            // CR3: no flow control

// Control/Status bits
.equ CR1_UARTEN,      (1 << 13)                         // CR1: UE bit → enable USART
.equ CR1_RE,		  (1 << 2)							//
.equ SR_TXE,          (1 << 7)                          // SR: TXE bit → transmit data register empty
.equ SR_RXNE,		  (1 << 5)							//

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
			bl 	uart_init									// Call UART init: enable clocks, set PA2 to AF7, set baud, enable TX

loop:
			bl	uart_readchar								//

        	b   loop                                        // Repeat endlessly


uart_init:
			/* Enable clock access to GPIOA */
	        ldr r0, =RCC_AHB1ENR                            // Load address of RCC_AHB1ENR into r0
	        ldr r1, [r0]                                    // Load current value at RCC_AHB1ENR into r1
	        orr r1, r1, #GPIOA_EN                           // OR r1 with GPIOA_EN → set bit 0 (enable GPIOA clock)
	        str r1, [r0]                                    // Store updated value back to RCC_AHB1ENR

	        /* Set PA2 to Alternate Function mode (MODER[5:4] = 10) */
	        ldr r0, =GPIOA_MODER                            // Load address of GPIOA_MODER into r0
	        ldr r1, [r0]                                    // Load current MODER into r1
	        bic r1, r1, #0x30                               // Clear bits 5:4 (PA2 mode bits) to 00 (input) first
	        orr r1, r1, #MODER2_ALT_SLT                     // OR r1 with (1<<5) → set bit 5 → bits 5:4 = 10 (AF mode)
	        str r1, [r0]                                    // Write back to GPIOA_MODER

			/* Set PA3 mode as ALT */
			ldr r0, =GPIOA_MODER                            // Load address of GPIOA_MODER into r0
	        ldr r1, [r0]                                    // Load current MODER into r1
	        bic r1, r1, #0xC0                               // Clear bits 5:4 (PA2 mode bits) to 00 (input) first
	        orr r1, r1, #MODER3_ALT_SLT                     // OR r1 with (1<<5) → set bit 5 → bits 5:4 = 10 (AF mode)
	        str r1, [r0]                                    // Write back to GPIOA_MODER

	        /* Select AF7 for PA2 (USART2_TX): AFRL[11:8] = 0b0111 */
	        ldr r0, =GPIOA_AFRL                             // Load address of GPIOA_AFRL into r0
	        ldr r1, [r0]                                    // Load current AFRL into r1
	        bic r1, r1, #0xF00                              // Clear bits 11:8 (AF field for PA2)
	        orr r1, r1, #PIN2_AF7_SLT                       //
	        str r1, [r0]                                    // Write back to GPIOA_AFRL

			/* Select AF7 for PA3 */
			ldr r0, =GPIOA_AFRL                             // Load address of GPIOA_AFRL into r0
	        ldr r1, [r0]                                    // Load current AFRL into r1
	        bic r1, r1, #0xF000                             //
	        orr r1, r1, #PIN3_AF7_SLT                       //
	        str r1, [r0]                                    // Write back to GPIOA_AFRL


	        /* Enable clock access to USART2 (APB1) */
	        ldr r0, =RCC_APB1ENR                            // Load address of RCC_APB1ENR into r0
	        ldr r1, [r0]                                    // Load current value at RCC_APB1ENR into r1
	        orr r1, r1, #USART2_EN                          // OR r1 with USART2_EN → set bit 17 (enable USART2 clock)
	        str r1, [r0]                                    // Write back to RCC_APB1ENR

	        /* Set USART2 baud rate */
	        ldr r0, =UART2_BRR                              // Load address of USART2 BRR into r0
	        mov r1, #BRR_CNF                                // Move 0x0683 (≈9600 @ 16 MHz) into r1
	        str r1, [r0]                                    // Write BRR

	        /* Enable UART RX */
	        ldr	r0, =UART2_CR1								//
	        mov	r1, #CR1_CNF								//
	        orr	r1, r1, #CR1_RE								//
	        str	r1, [r0]									//

	        /* Configure control registers (8N1, TX enable, UE later) */
	        ldr r0, =UART2_CR1                              // Load address of USART2 CR1 into r0
	        mov r1, #CR1_CNF                                // Move CR1 config (TE=1, UE=0 for now) into r1
	        str r1, [r0]                                    // Write CR1

	        ldr r0, =UART2_CR2                              // Load address of USART2 CR2 into r0
	        mov r1, #CR2_CNF                                // Move CR2 config (1 stop bit) into r1
	        str r1, [r0]                                    // Write CR2

	        ldr r0, =UART2_CR3                              // Load address of USART2 CR3 into r0
	        mov r1, #CR3_CNF                                // Move CR3 config (no flow control) into r1
	        str r1, [r0]                                    // Write CR3

	        /* Enable USART2 module (UE=1) */
	        ldr r0, =UART2_CR1                              // Load address of USART2 CR1 into r0
	        ldr r1, [r0]                                    // Read current CR1 into r1
	        orr r1, r1, #CR1_UARTEN                         // OR r1 with UE bit → enable USART
	        str r1, [r0]                                    // Write CR1 back

	        bx  lr                                          // Return from uart_init

uart_readchar:
        	ldr r1, =UART2_SR                               // Load address of USART2 SR into r1

wait_txe:
	        ldr r2, [r1]                                    // Load current SR into r2
	        add r2, #SR_RXNE                            	//
	        cmp r2, #0x00                                   // Compare r2 with 0 (is TXE still 0?)

	        beq wait_txe                                    // If equal, TXE=0 → wait until TXE becomes 1

	        ldr r3, =UART2_DR                               // Load address of USART2 DR into r2
	        ldr r0, [r3]                               		//

			bx  lr                                          // Return from uart_readchar

uart_outchar:
        	ldr r1, =UART2_SR                               // Load address of USART2 SR into r1

wait_txe2:
	        ldr r2, [r1]                                    // Load current SR into r2
	        and r2, r2, #SR_TXE                             // Mask SR with TXE bit → r2 = TXE (0 or non-zero)
	        cmp r2, #0x00                                   // Compare r2 with 0 (is TXE still 0?)

	        beq wait_txe2                                   // If equal, TXE=0 → wait until TXE becomes 1

	        // TXE=1 (data register empty): write the character
	        mov r1, r0                                      // Move the character from r0 into r1 (source for store)
	        ldr r2, =UART2_DR                               // Load address of USART2 DR into r2
	        str r1, [r2]                                    // Store r1 to DR (launch transmit of this character)

	        bx  lr                                          // Return from uart_outchar



			.align
			.end						// Required to end program

