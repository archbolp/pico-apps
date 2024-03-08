
#include "hardware/regs/addressmap.h" 
#include "hardware/regs/io_bank0.h" 
#include "hardware/regs/timer.h" 
#include "hardware/regs/m0plus.h"

.syntax unified
.cpu cortex-m0plus 
.thumb
.global main_asm 
.global isr
.align 4

.equ DFLT_STATE_STRT, 1 @ Specify the value to start flashing
.equ DFLT_STATE_STOP, 0 @ Specify the value to stop flashing
.equ DFLT_ALARM_TIME, 1000000 @ Specify the default alarm timeout

.equ GPIO_BTN_DN_MSK, 0x00040000 @ Bit-18 for falling-edge event on GP20
.equ GPIO_BTN_EN_MSK, 0x00400000 @ Bit-22 for falling-edge event on GP21
.equ GPIO_BTN_UP_MSK, 0x04000000 @ Bit-26 for falling-edge event on GP22

.equ GPIO_BTN_DN, 20 @ Specify pin for the "down" button
.equ GPIO_BTN_EN, 21 @ Specify pin for the "enter" button
.equ GPIO_BTN_UP, 22 @ Specify pin for the "up" button
.equ GPIO_LED_PIN, 25 @ Specify pin for the built-in LED
.equ GPIO_DIR_IN, 0 @ Specify input direction for a GPIO pin
.equ GPIO_DIR_OUT, 1 @ Specify output direction for a GPIO pin
.equ LED_VAL_ON, 1 @ Specify value that turns the LED "on"
.equ LED_VAL_OFF, 0 @ Specify value that turns the LED "off"
.equ GPIO_ISR_OFFSET, 0x74 @ GPIO is int #13 (vector table entry 29)
.equ ALRM_ISR_OFFSET, 0x40 @ ALARM0 is int #0 (vector table entry 16)

@ Entry point to the ASM portion of the program
main_asm:
    bl      init_gpio_led_and_buttons      @ Initialise the GPIO LED pin
   
    bl      install_isr

    bl      alarm_interrupt             

main_loop:
        b main_loop

init_gpio_led_and_buttons:
    @initiate leds same as lab05 + the necessary buttons
    push    {lr}
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board r0
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board r0
    movs    r1, #LED_GPIO_OUT           @ We want this GPIO pin to be setup as an output pin r1 
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to direction(state) r1
    movs    r0, #GPIO_BTN_DN            @ This value is the GPIO button pin20 r0
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN_DN            @ This value is the GPIO button pin20 r0
    bl      gpio_set_irq_enabled        @ Call subroutine to set gpio pin to enable interrupts
    movs    r0, #GPIO_BTN_EN            @ This value is the GPIO button pin21 r0
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN_EN            @ This value is the GPIO button pin21 r0
    bl      gpio_set_irq_enabled        @ Call subroutine to set gpio pin to enable interrupts
    movs    r0, #GPIO_BTN_UP            @ This value is the GPIO button pin22 r0
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN_UP            @ This value is the GPIO button pin22 r0
    bl      gpio_set_irq_enabled        @ Call subroutine to set gpio pin to enable interrupts
    pop     {pc}

install_isr:

alarm_interrupt:

down_button:

enter:

up_button:

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





.align 4
msg: .asciz "Hello World!\n"
.data
lstate: .word DFLT_STATE_STRT 
ltimer: .word DFLT_ALARM_TIME
