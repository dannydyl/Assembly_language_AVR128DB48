
start:
    ; Configure I/O ports
	cbi VPORTC_DIR, 0	;PORTC input
	ldi r16, 0x0F		;make initial count value 0
    out VPORTC_DIR, r16

	;Configure interrupt request
	lds r16, PORTE_PIN0CTRL	;set ISC for PE0 to rising edge
	ori r16, 0x02		;ISC = 2 for rising edge
	sts PORTE_PIN0CTRL, r16
   
main_loop:		;main program loop
	;Determine if PE0's INTF is set
	lds r16, PORTE_INTFLAGS	;check for PE0 IRQ flag set
	sbrc r16, 0
	rcall output_bar			;execute subroutine for PE0
	rjmp main_loop

;Subroutine called for PE0 INTF set
output_bar:		;PE0's task to be done

	in r18, VPORTC_IN	// gets the input from DIP switch and keypad

    lsr r18
    lsr r18
    lsr r18
    lsr r18

    com r18			// complement r19 for display
    out VPORTD_OUT, r18	// display

    // just like clearing flip flop
	ldi r16, PORT_INT0_bm	;clear IRQ flag for PE0
	sts PORTE_INTFLAGS, r16
	ret
