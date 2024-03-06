#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"

.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment

.equ    SLEEP_TIME, 500         @ Specify the sleep time (in ms)
.equ    LED_GPIO_PIN, 25        @ Specify the pin that the LED is connected to
.equ    LED_GPIO_OUT, 1         @ Specify the direction of the GPIO pin
.equ    LED_VALUE_ON, 1         @ Specify the value that turns the LED "on"
.equ    LED_VALUE_OFF, 0        @ Specify the value that turns the LED "off"
.equ    SVC_ISR_OFFSET, 0x2C    @ The SVC is entry 11 in the vector table
.equ    SVC_MAX_INSTRS, 0x01    @ Maximum allowed SVC subroutines

@ Entry point to the ASM portion of the program
main_asm:
    bl      init_gpio_led       @ Initialise the GPIO LED pin
    bl      install_svc_isr     @ Install the SVC interrupt service routine
loop:
    svc     #0                  @ Call the SVC ISR with value 0 (turns on LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Short pause before proceeding
    svc     #1                  @ Call the SVC ISR with value 1 (turns off LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Add a short pause before proceeding
    b       loop                @ Always jump back to the start of the loop
 
@ Subroutine used to introduce a short delay in the application
do_sleep:
    push    {lr}                        @ Store the link register to the stack 
    ldr     r0, =SLEEP_TIME             @ Set the value of SLEEP_TIME we want to wait for stored in r0
    bl      sleep_ms                    @ Sleep until SLEEP_TIME has elapsed then toggle the LED GPIO pin
    pop     {pc}                        @ pop link register from stack to the program counter

@ Subroutine used to initialise the PI Pico built-in LED
init_gpio_led:
@same as lab3 without button
    push    {lr}                        @ Store the link register to the stack 
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board r0
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board r0
    movs    r1, #LED_GPIO_OUT           @ We want this GPIO pin to be setup as an output pin r1 
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to direction(state) r1
    pop     {pc}                        @ pop link register from stack to the program counter
    
@ Subroutine used to install the SVC interrupt service handler
install_svc_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)    @ PPB_BASE & M0PLUS_VTOR_OFFSET added and address is loaded into r2 
    ldr     r1, [r2]                                @ address in r2 loaded into r1
    movs    r2, #SVC_ISR_OFFSET                     @ SVC_ISR_OFFSET value moved to r2
    add     r2, r1                                  @ adds r1 & r2 = address svc handler should be installed at
    ldr     r0, =svc_isr                            @ r0 used to store address of svc_isr (routine)
    str     r0, [r2]                                @ address of svc routine stored in our calculated svc handler address
    bx      lr                                      @ leave subroutine

@ SVC interrupt service handler routine
.thumb_func                     @ Required for all interrupt service routines
svc_isr:
    push    {lr}                @ Store the link register to the stack 
    ldr     r0, [sp, #0x1C]     @ loads value stack pointer with offset 0x1C into r0
    subs    r0, #0x2            @ value in r2 - 2
    ldr     r0, [r0]            @ load value from address pointed at by r0 into r0
    ldr     r1, =#0xFF          @ loads value 0xFF into r1
    ands    r0, r1              @ r0 AND r1
    cmp     r0, #SVC_MAX_INSTRS @ compare max allowed svc subroutines to r0's value
    bgt     svc_done            @ if r0 > max allowed branch to end of subroutine
    adr     r1, svc_jmptbl      @ adress of svc_jmptbl loaded into r1
    lsls    r0, #2              @ left shift value in r0 by 2 bits
    ldr     r1, [r1, r0]        @ load value from svc_jmptbl + offset into r1
    mov     pc, r1              @ value in r1 moved to pc
svc_done:
    pop     {pc}                @ pop link register from stack to the program counter

    @ First function of SVC subroutine - turn on the LED
svc_num0:
    movs    r0, #LED_GPIO_PIN   @ This value is the GPIO LED pin on the PI PICO board r0
    movs    r1, #LED_VALUE_ON   @ This sets value of r1 to be LED value "on"
    bl      asm_gpio_put        @ Call the subroutine to set the GPIO pin value
    b       svc_done            @ Branch back to the main ISR when done
 
@ Second function of SVC subroutine - turn off the LED
svc_num1:
    movs    r0, #LED_GPIO_PIN   @ This value is the GPIO LED pin on the PI PICO board r0
    movs    r1, #LED_VALUE_OFF  @ This sets value of r1 to be LED value "off"
    bl      asm_gpio_put        @ Call the subroutine to set the GPIO pin value
    b       svc_done            @ Branch back to the main ISR when done

@ SVC function entry jump table.
.align 2
svc_jmptbl:
    .word svc_num0              @ Entry zero goes to SVC function #0.
    .word svc_num1              @ Entry one goes to SVC function #1.
    .word 0                     @ Null termination of the jump table.

@ Set data alignment
.data
     .align 4
