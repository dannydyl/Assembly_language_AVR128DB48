;
; logic_ops.asm
;
; Created: 9/28/2023 9:57:38 AM
; Author : userESD
;


; Replace with your application code
start:
    ldi r16, 0xFF		;load r16 with all 1s
	out VPORTD_DIR, r16	;PORTD - all pins configured as outputs
	ldi r16, 0x00		;load r16 with all 0s
	out VPORTC_DIR, r16	;PORTC - all pins configured as inputs

main_loop:
	in r16, VPORTC_IN	;read switch values
	mov r17, r16		;image for A
	mov r18, r16		;image for B
	andi r17, 0xE0		;mask for A
	andi r18, 0x1C		;mask for B
	lsl r18				;left justify B
	lsl r18
	lsl r18
	andi r16, 0x03		;mask for F
	cpi r16, 0x00		;is it and AND function
	breq and_fcn
	cpi r16, 0x02		;is it an XOR
	breq xor_fcn
not_fcn:				;compute NOT, default
	com r17
	mov r18, r17
	rjmp output
and_fcn:				;compute AND
	and r18, r17
	rjmp output
or_fcn:					;compute OR
	or r18, r16
	rjmp output
xor_fcn:				;compute XOR
	eor r18, r17
output:
	andi r18, 0xE0		;output result
	com r18
	out VPORTD_OUT, r18
	rjmp main_loop