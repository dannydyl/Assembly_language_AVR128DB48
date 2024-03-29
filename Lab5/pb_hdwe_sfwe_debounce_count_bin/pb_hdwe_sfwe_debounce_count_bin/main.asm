;
; prelab-task2.asm
;
; Created: 10/2/2023 4:23:59 PM
; Author : CAD
;


; Replace with your application code
start:
    ldi r16, 0xFF		; set PD output LED bargraph
	out VPORTD_DIR, r16
	ldi r16, 0x00		;set PE input pushbutton

	cbi VPORTE_DIR, 0	//PE0 input
	cbi VPORTE_DIR, 2	// input directly from pushbutton
	sbi VPORTE_DIR, 1	// PE1 output for CLR
	sbi VPORTE_OUT, 1

wait_for_1:
	sbis VPORTE_IN, 0	;wait for PE0 being 1
rjmp wait_for_1		;skip this line if PE0 is 1

	rjmp output		; jump to output

wait_for_0_delay_after:	;comes here after output
	sbic VPORTE_IN, 2
rjmp wait_for_0_delay_after	;skips this line if PE0 is 0

ldi r16, 80
delay_break:			;delay lable for break delay
outer_loop_break:
	ldi r17, 133
	inner_loop_break:
		dec r17
	brne inner_loop_break
dec r16
brne outer_loop_break

	sbic VPORTE_IN, 2
rjmp wait_for_0_delay_after	;skips this line if PE0 is 0


	cbi VPORTE_OUT, 1
	sbi VPORTE_OUT, 1

	rjmp wait_for_1	;go back to start

	
check_full:
	cpi r17, 0xFF	; check if r16 is 0xFF which is full
	breq reset		; if it is true that r16 is equal to 0xFF, go to reset
ret
reset:
	ldi r17, 0x00
ret

output:
	rcall check_full
	inc r19
	mov r18, r19
	com r18
	out VPORTD_OUT, r18

	rjmp wait_for_0_delay_after	; jump to wait for 0 but that has delay after

	display:
	in r16, VPORTC_DIR
	com r16
	out r16, VPORTD_DIR