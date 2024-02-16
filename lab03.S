.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment

.equ    SLEEP_TIME, 10          @ Specify the amount of ms that we want to sleep for when waiting for button
.equ    LED_GPIO_PIN, 25        @ Specifiy the physical GPIO pin that the LED is connected to
.equ    LED_GPIO_OUT, 1         @ Specify the direction that we want to set the GPIO pin to
.equ    LED_VALUE_ON, 1         @ Specify the value that turns the LED "on"
.equ    LED_VALUE_OFF, 0        @ Specify the value that turns the LED "off"
.equ    button_input, 21        @ Specify the physical GPIO pin that goes to the button (21)
.equ    button_direction, 0     @ Specify the direction that we want to set the button pin to
.equ    on_button, 1            @ Specify the value that exists when the button is being pressed
.equ    off_button, 0           @ Specify the value that exists when the button not being pressed



main_asm:
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board r0
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #button_input           @ This value is the GPIO button pin21 r0
    bl      asm_gpio_init               @  Call the subroutine to initialise the buttons pin
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board r0
    movs    r1, #LED_GPIO_OUT           @ We want this GPIO pin to be setup as an output pin r1
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to direction(state) r1
    movs    r0, #button_input           @ This value is the GPIO button pin21 r0
    movs    r1, #button_direction       @ We want this GPIO button pin to be setup as an output pin r1
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO button pin specified by r0 to direction(state) r1

loop:
    ldr     r0, =SLEEP_TIME             @ Set the value of SLEEP_TIME we want to wait for stored in r0
    bl      sleep_ms                    @ Sleep until SLEEP_TIME has elapsed then toggle the LED GPIO pin
    bl      button                      @ Call button subroutine which checks if button is being pressed
    b       loop                        @ Repeat the loop until button pressed

@ Subroutine to toggle the LED GPIO pin value once button has been pressed
button:
    push    {lr}                        @ Store the link register to the stack as we will call nested subroutines
    movs    r0, #button_input           @ This value is the GPIO button pin21 stored in r0
    bl      asm_gpio_get                @ Get current the value of the LED GPIO pin (returns to r0)
    cmp     r0, #off_button             @ Check if button is not being pressed (as its checking for off)
    bne     sub_toggle                  @ If the button is being pressed keep checking until released

button_end:
    pop     {pc}                        @ pop link register from stack to the program counter

sub_toggle:
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_get
    bl      asm_gpio_get                @ Get current the value of the LED GPIO pin (returns to r0)
    cmp     r0, #LED_VALUE_OFF          @ Check if the LED GPIO pin value is "off"
    beq     led_set_on                  @ If it is "off" then then jump code to to turn it on

led_set_off:
    movs    r1, #LED_VALUE_OFF          @ The LED is currently "on" so we want to turn it "off"
    b       led_set_state               @ Jump to portion of code where we set the state of the LED

led_set_on:
    movs    r1, #LED_VALUE_ON           @ The LED is currently "off" so we want to turn it "on"

led_set_state:
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put                @ Update the the value of the LED GPIO pin (based on value in r1)

wait_period:
    movs    r0, #button_input           @ This value is the GPIO button pin21 stored in r0
    bl      asm_gpio_get                @ Get current the value of the LED GPIO pin (returns to r0)
    cmp     r0, #off_button             @ Check if button is not being pressed (as its checking for off)
    bne     wait_period                 @ If button is still being pressed wait and loop subroutine to check again until not being pressed
wait_period_end:    
    pop     {pc}                        @ pop link register from stack to the program counter

@ Set data alignment
.data
    .align 4