;***************************************************************************
;*
;* Title: Polling INT0 to Count Pushbutton Presses
;* Author:				Ken Short
;* Version:				1.0
;* Last updated:		
;* Target:				AVR128DB48 @4.0MHz
;*
;* DESCRIPTION
;* Polls positive edge triggered pin change interrupt flag INT0 to count
;* the number of times a pushbutton is pressed. Global interrupt (I) is not
;* enabled, so no interrupt actually occurs. Pushbutton is connected to PE0.
;* The pushbutton press count is stored in a byte memory variable.
;*
;* VERSION HISTORY
;* 1.0 Original version
;***************************************************************************

.dseg					;start of data segment
PB_count: .byte 1		;pushbutton press count memory variable.

.cseg					;start of code segment
start:
    ; Configure I/O ports
	cbi VPORTE_DIR, 0	;PE0 input- output of debounced PB
	ldi r16, 0x00		;make initial count value 0
	sts PB_count, r16

	;Configure interrupt request
	lds r16, PORTE_PIN0CTRL	;set ISC for PE0 to rising edge
	ori r16, 0x02		;ISC = 2 for rising edge
	sts PORTE_PIN0CTRL, r16
   
main_loop:		;main program loop
	;Determine if PE0's INTF is set
	lds r16, PORTE_INTFLAGS	;check for PE0 IRQ flag set
	sbrc r16, 0
	rcall PB_sub			;execute subroutine for PE0
	rjmp main_loop

;Subroutine called for PE0 INTF set
PB_sub:		;PE0's task to be done
	lds r16, PB_count		;get current count for PB
	inc r16					;increment count
	sts PB_count, r16		;store new count
	ldi r16, PORT_INT0_bm	;clear IRQ flag for PE0
	sts PORTE_INTFLAGS, r16
	ret

