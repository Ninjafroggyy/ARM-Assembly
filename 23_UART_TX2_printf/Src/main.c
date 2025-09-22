
#include <stdio.h>

extern void uart_init(void);
extern void uart_outchar(int ch);


int __io_putchar(int ch) {
	uart_outchar(ch);
	return ch;
}

int main() {
	uart_init();

	while(1) {
		printf("Hello from STM32 UART Driver \n\r");
	}
}



