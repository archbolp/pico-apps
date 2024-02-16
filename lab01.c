#include "pico/stdlib.h"

/**
 * @brief EXAMPLE - BLINK_C
 *        Simple example to initialise the built-in LED on
 *        the Raspberry Pi Pico and then flash it forever. 
 * 
 * @return int  Application return code (zero for success).
 */
int main() {

    // Specify the PIN number and sleep delay
    inf(25,500);

    // Should never get here due to infinite while-loop.
    return 0;

}

int inf(uint LED_PIN, uint LED_DELAY){
// Setup the LED pin as an output.
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
// Do forever...
    while (true) {

        // Toggle the LED on and then sleep for delay period
        gpio_put(LED_PIN, 1);
        sleep_ms(LED_DELAY);

        // Toggle the LED off and then sleep for delay period
        gpio_put(LED_PIN, 0);
        sleep_ms(LED_DELAY);

    }
    return 0;
}