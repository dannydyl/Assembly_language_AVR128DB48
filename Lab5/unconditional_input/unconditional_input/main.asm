;
; unconditional_input.asm
;
; Created: 10/2/2023 6:46:55 PM
; Author : CAD
;

start:
    ldi r16, 0xFF		; set PD output LED bargraph
	out VPORTD_DIR, r16
	ldi r16, 0x00		;set PE input pushbutton
	out VPORTC_DIR, r16

again:
	in r16, VPORTC_IN
	com r16
	out VPORTD_OUT, r16
	rjmp again
