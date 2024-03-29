;
; AssemblerApplication2.asm
;
; Created: 9/20/2023 5:48:23 PM
; Author : CAD
;


;PB2 reads SW0 and PB3 drives LED0
start:
    sbi VPORTD_DIR, 7	;set direction of PD3 as output
	sbi VPORTD_OUT, 7	;set output value to 1
	cbi VPORTA_DIR, 7	;set direction of PB2 to input (default)
	ldi r16, 0x08		;enable internal pull-up resistor at PB2
	sts PORTA_PIN7CTRL, r16

;Read switch position to control LED
loop:
	sbis VPORTA_IN, 7	;skip next instruction if PB2 is 1
	cbi VPORTD_OUT, 7	;clear output PB3 to 0, turn LED ON
	sbic VPORTA_IN, 7	;skip next instruction if PB2 is 0
	sbi VPORTD_OUT, 7	;set output PB3 to 1, turn LED OFF
	rjmp loop			;jump back to loop
