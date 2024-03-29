;
; TCA0_PWM.asm
;
; Created: 12/1/2023 7:31:24 PM
; Author : kshort
;

;This is a demo program of using TCA0 in single-slope PWM mode to genrate
;a PWM signal at pin PD0. Since in Laboratory 11 you are setting a duty
;cycle between 0 and 100% and only need to set it to a resolution of 1%, the
;PER register is set to 100. Compare register CMP0 is being used to make the
;comparison. Since PER is set to 100 the value set in CMP0 is the actual
;desired duty cycle.

;When running this program on the microcontroller, you can simply pause the
;exeution and directly write a new value into CMP0 to change the duty cycle.

;Interrupts are not used in this program, but a jmp is provided at the start
;to jump over an interrupt table.

;In your Laboratory 11 program you will need to use double buffering. When doing
;so the register you would write in your program would be CMP0BUF instead of
;CMP0. However, when emulating the program, if you pause the program and want to
;change the duty cycle, you must manually change the value in CMP0 and not
;CMP0BUFF.

;There is no code in this program to create the sych pulse for the oscilloscope.
;However, the output pin for the synch pulse is configured. The code uses the
;predefined names for the values loaded into control registers so that you can
;see an example of a program where this is done.


.equ PERIOD_EXAMPLE_VALUE = 100		; 1% resolution for duty cycle setting
.equ DUTY_CYCLE_EXAMPLE_VALUE = 25	;desired duty cycle as percent

reset:
	jmp start		;restart vector to jump over a vector table
	;Interrupt vector table goes here


start:
	;Configure ports
    sbi VPORTD_DIR, 0	;make PD0 an output, PWM waveform output pin
	cbi VPORTD_OUT, 0	;initial output value is 0
	sbi VPORTD_DIR, 1	;make PD1 an output, duty cycle change synch pulse
	cbi VPORTD_OUT, 1	;initial value is 0

	;Route WO0 to PD0 instead of its default pin PA0
	ldi r16, 0x03		;mux TCA0 WO0 to PD0
	sts PORTMUX_TCAROUTEA, r16

	;Set CTRLB to use CMP0 and single slope PWM
	ldi r16, TCA_SINGLE_CMP0EN_bm | TCA_SINGLE_WGMODE_SINGLESLOPE_gc ;CMP0EN and single slope PWM
	sts TCA0_SINGLE_CTRLB, r16

	;Load low byte then high byte of PER period register
	ldi r16, LOW(PERIOD_EXAMPLE_VALUE)		;set the period
	sts TCA0_SINGLE_PER, r16
	ldi r16, HIGH(PERIOD_EXAMPLE_VALUE)
	sts TCA0_SINGLE_PER + 1, r16

	;Load low byte and the high byte of CMP0 compare register
	ldi r16, LOW(DUTY_CYCLE_EXAMPLE_VALUE)		;set the duty cycle
	sts TCA0_SINGLE_CMP0, r16	;use TCA0_SINGLE_CMP0BUF for double buffering
	ldi r16, HIGH(DUTY_CYCLE_EXAMPLE_VALUE)
	sts TCA0_SINGLE_CMP0 + 1, r16

	;Set clock and start timer/counter TCA0
	ldi r16, TCA_SINGLE_CLKSEL_DIV64_gc | TCA_SINGLE_ENABLE_bm
	sts TCA0_SINGLE_CTRLA, r16

	;Timer/counter is now running and generating PWM output independently
	;of the CPU's program execution

main_loop:
	nop			;no tasks performed by main loop
	rjmp main_loop


