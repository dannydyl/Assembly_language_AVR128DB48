;
; prelab-task1.asm
;
; Created: 10/2/2023 4:23:59 PM
; Author : CAD
;


; Replace with your application code
start:
    ldi r16, 0xFF		; set PD output
	out VPORTD_DIR, r16
	ldi r16, 0x00		;set PE input
	out VPORTE_DIR, r16

wait_for_0:
	sbic VPORTE_IN, 0	;wait for PE0 being 0
	rjmp wait_for_0		
wait_for_1:
	sbis VPORTE_IN, 0	;wait for PE0 being 1
	rjmp wait_for_1
	

check_full:
	cpi r16, 0xFF	; check if r16 is 0xFF which is full
	breq reset		; if it is true that r16 is equal to 0xFF, go to reset
	rjmp output

reset:
	ldi r16, 0x00
	rjmp wait_for_0

output:
	inc r16
	com r16
	out VPORTD_OUT, r16
	com r16
	rjmp wait_for_0

