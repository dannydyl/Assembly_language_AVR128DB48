start:
    ldi r17, 0x00
    out VPORTC_DIR, r17
    sbi VPORTD_DIR, 0


main_loop:
    in r16, VPORTC_IN   // get input from switch

	andi r16, 0x0F  // mask 0000 1111 4 least significant bits

    rcall lookup
	
    cpi r16, 0x00
    breq always_off
    cpi r16, 0x01
    breq r16_is_1
    cpi r16, 0x02
    breq r16_is_2
    cpi r16, 0x03
    breq r16_is_3
    cpi r16, 0x04
    breq r16_is_4
    cpi r16, 0x05
    breq r16_is_5
    cpi r16, 0x06
    breq r16_is_6
    cpi r16, 0x07
    breq r16_is_7
    cpi r16, 0x08
    breq r16_is_8
    cpi r16, 0x09
    breq r16_is_9
    cpi r16, 0x0A
    breq r16_is_A
    cpi r16, 0x0B
    breq r16_is_B
    cpi r16, 0x0C
    breq r16_is_C
    cpi r16, 0x0D
    breq r16_is_D
    cpi r16, 0x0E
    breq r16_is_E
    cpi r16, 0x0F
    breq always_on

    rjmp main_loop


r16_is_1:
    ldi r16, 238
    rjmp timing_loop

r16_is_2:
    ldi r16, 221
    rjmp timing_loop

r16_is_3:
    ldi r16, 204
    rjmp timing_loop

r16_is_4:
    ldi r16, 187
    rjmp timing_loop

r16_is_5:
    ldi r16, 170
    rjmp timing_loop

r16_is_6:
    ldi r16, 153
    rjmp timing_loop

r16_is_7:
    ldi r16, 136
    rjmp timing_loop

r16_is_8:
    ldi r16, 119
    rjmp timing_loop

r16_is_9:
    ldi r16, 102
    rjmp timing_loop

r16_is_A:
    ldi r16, 85
    rjmp timing_loop

r16_is_B:
    ldi r16, 68
    rjmp timing_loop

r16_is_C:
    ldi r16, 51
    rjmp timing_loop

r16_is_D:
    ldi r16, 34
    rjmp timing_loop

r16_is_E:
    ldi r16, 17
    rjmp timing_loop

r16_is_F:
    ldi r16, 0
    rjmp always_on

always_off:
	cbi VPORTD_OUT, 0

	rjmp main_loop

always_on:
    sbi VPORTD_OUT, 0

    rjmp main_loop

timing_loop:

    ldi r20, 255
    sub r20, r16


    loop:
        sbi VPORTD_OUT, 0

    dec_loop:
        dec r20
        brne loop

        cbi VPORTD_OUT, 0

    loop2:
        cbi VPORTD_OUT, 0

    dec_loop2:
        dec r16
        brne loop2

        sbi VPORTD_OUT, 0
        rjmp main_loop
   

table: .db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F

lookup:
	ldi ZH, high (table*2)
	ldi ZL, low (table*2)
	ldi r18, $00
	add ZL, r16	
	adc ZH, r18
	lpm r16, Z
	
	ret
    