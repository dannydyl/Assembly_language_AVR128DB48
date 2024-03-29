;
; sws_positions.asm
;
; Created: 9/28/2023 9:45:54 AM
; Author : userESD
;


; Replace with your application code
start:
    ;configure I/O ports
	ldi r16, 0xFF		;load r16 with all 1s
	out VPORTD_DIR, r16	;PORTD - all pins configured as outputs
	ldi r16, 0x00		;load r16 with all 0s
	out VPORTC_DIR, r16	;PORTA - all pins configured as inputs

	;Continually input switch values and output to LEDs
again:
	in r16, VPORTC_IN	;read switch values
	com r16				;complement switch values to drive LEDs
	out VPORTD_OUT, r16	;output to LEDs complement input from switches
	rjmp again			;continually repeat previous three instructions