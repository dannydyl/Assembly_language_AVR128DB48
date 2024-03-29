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

	sbi VPORTB_OUT, 4	//turn off the clear button

wait_for_1:
	sbis VPORTB_IN, 5	;wait for PB5 being 1
rjmp wait_for_1		;skip this line if PE0 is 1

// $ = 0x
table: .db $01, $02, $03, $0F, $04, $05, $06, $0E, $07, $08, $09, $0D, $0A, $00, $0B, $0C


output:
in r18, VPORTC_IN	// gets the input from DIP switch and keypad

lsr r18		// shifting  to right 4 bits
lsr r18
lsr r18
lsr r18

//mov r19, r18			// copy it to another register

// lookup table from lecture
lookup:
	ldi r16, 0x00
	ldi ZH, high (table*2)
	ldi ZL, low (table*2)
	ldi r16, $00
	add ZL, r18	
	adc ZH, r16
	lpm r20, Z
	;add r19, r20


com r20				// complement r19 for display
out VPORTD_OUT, r20	// display


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

rjmp wait_for_1		// go back to the start





