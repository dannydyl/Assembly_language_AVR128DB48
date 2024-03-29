;
; Keypad mapping test
;
; Created: 10/11/2023 3:17:11 PM
; Author : CAD
;


start:
    ldi r16, 0xFF	//make into output
	out VPORTD_DIR, r16
	ldi r16, 0x00	//make into input
	out VPORTC_DIR, r16
	
	sbi VPORTB_DIR, 4	; makes PB4(clear) to output
	cbi VPORTB_DIR, 5	// input directly from pushbutton



wait_for_1:
	sbis VPORTB_IN, 5	;wait for PB5 being 1
rjmp wait_for_1		;skip this line if PE0 is 1


bcd_7seg:
	andi r18, $0F
	cpi r18, 10
	brlo lookup
	clc
	ldi r18, 0
	ret
lookup:
	ldi ZH, high (segtable * 2)
	ldi ZL, low (segtable * 2)
	ldi r16, $00
	add ZL, r18
	adc ZH, r16
	lpm r18, Z
	sec
	ret

segtable: .db $7E, $30, $6D, $79, $33, $5B, $5F, $70, $7F, $7B


output:

in r18, VPORTC_IN	// gets the input from DIP switch and keypad

mov r18, 19			// copy it to another register

com r19				// complement r19 for display
out VPORTD_OUT, r19	// display


delay_break:			;delay lable for break delay
	ldi r16, 80
	outer_loop_break:
		ldi r17, 133
		inner_loop_break:
			dec r17
	brne inner_loop_break
		dec r16
brne outer_loop_break

clear_flipflop:		// clear the flip flop for next input
	cbi VPORTB_OUT, 4
	sbi VPORTB_OUT, 4

clear_check:		// check if the clear has worked properly
	sbic VPORTB_IN, 5
	rjmp delay_break

rjmp wait_for_1		// go back to the start


