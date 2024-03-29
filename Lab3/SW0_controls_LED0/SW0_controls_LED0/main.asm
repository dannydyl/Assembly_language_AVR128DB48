;PA7 reads SW0 and PD7 drives LED0
start:
	sbi VPORTD_DIR, 7 ;set direction of PD3 as output
	sbi VPORTD_OUT, 7 ;set output value to 1
	cbi VPORTA_DIR, 7 ;set direction of PA7 to input (default)
	ldi r16, 0x08 ;enable internal pull-up resistor at PA7
	sts PORTA_PIN7CTRL, r16
;Read switch position to control LED
loop:
	sbis VPORTA_IN, 7 ;skip next instruction if PA7 is 1
	cbi VPORTD_OUT, 7 ;clear output PD7 to 0, turn LED ON
	sbic VPORTA_IN, 7 ;skip next instruction if PA7 is 0
	sbi VPORTD_OUT, 7 ;set output PD7 to 1, turn LED OFF
	rjmp loop ;jump back to loo