;
; AssemblerApplication1.asm
;
; Created: 9/20/2023 4:57:58 PM
; Author : CAD
;


;PB2 reads SW0 and PB3 drives LED0
start:
    sbi VPORTB_DIR, 3	;set direction of PB3 as output
	sbi VPORTB_OUT, 3	;set output value to 1
	cbi VPORTB_DIR, 2	;set direction of PB2 to input (default)
	ldi r16, 0x08		;enable internal pull-up resistor at PB2
	sts PORTB_PIN2CTRL, r16

;Read switch position to control LED
loop:
	sbis VPORTB_IN, 2	;skip next instruction if PB2 is 1
	cbi VPORTB_OUT, 3	;clear output PB3 to 0, turn LED ON
	sbic VPORTB_IN, 2	;skip next instruction if PB2 is 0
	sbi VPORTB_OUT, 3	;set output PB3 to 1, turn LED OFF
	rjmp loop			;jump back to loop
