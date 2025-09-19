#include <stdint.h>

extern void adc_init(void);
extern uint32_t adc_read(void);
extern void led_init(void);
extern void led_control(void);


uint32_t sensor_value;


int main(void) {
	led_init();
	adc_init();

	while(1) {
		sensor_value = adc_read();
		led_control();
	}
}
