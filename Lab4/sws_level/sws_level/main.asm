;
; sws_level.asm
;
; Created: 9/28/2023 10:12:38 AM
; Author : userESD
;


start:
    ldi r16, 0xFF		;load r16 with all 1s
	out VPORTD_DIR, r16	;PORTD - all pins configured as outputs
	ldi r16, 0x00		;load r16 with all 0s
	out VPORTC_DIR, r16	;PORTC - all pins configured as inputs

main_loop:				;main_loop takes 54 clocks
	in r16, VPORTC_IN	;read switch values

	;Code to count swithces in '1's position and output to bargraph
	ldi r17, 8			;loop parameter for inner loop
	ldi r18, $00		;initial value of image to be output to bargraph LEDs
	
next_bit:

	lsl r16				;shift msb of r16 into carry
	brcc dec_bitcounter	;branch if carry clear
	rol r18

dec_bitcounter:
	dec r17
	brne next_bit		;branch if result after dec is not zero
	com r18				;complement bargraph image
	out VPORTD_OUT, r18	;output image to bargraph
	rjmp main_loop		
