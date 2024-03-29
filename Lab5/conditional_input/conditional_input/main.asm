;
; conditional_input.asm
;
; Created: 10/2/2023 6:53:51 PM
; Author : CAD
;


; Replace with your application code
start:
    ldi r16, 0xFF	//make into output
	out VPORTD_DIR, r16
	ldi r16, 0x00	//make into input
	out VPORTC_DIR, r16
	
	cbi VPORTE_DIR, 0	; makes PE0(pushbutton) to input
	sbi VPORTE_DIR, 1	; makes PE1(clear) to output
	cbi VPORTE_DIR, 2	// input directly from pushbutton

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


output:

	in r18, VPORTC_IN
	com r18
	out VPORTD_OUT, r18

	rjmp wait_for_0_delay_after	; jump to wait for 0 but that has delay after