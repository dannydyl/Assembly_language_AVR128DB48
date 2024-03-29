;
; dog_lcd_test_avr128.asm
;
; Created: 10/9/2023 2:14:29 PM
; Author : kshort
;


;*****************************************************************
;**********        BASIC DOG LCD TEST PROGRAM           **********
;*****************************************************************
;
;DOG_LCD_BasicTest.asm
;  Simple test application to verify DOG LCD is properly 
;  wired.  This test writes simple test messages to each 
;  line of the display.
;
;Version - 2.0 For DOGM163W LCD operated at 3.3V
;

     .CSEG

     ; interrupt vector table, with several 'safety' stubs
     rjmp RESET      ;Reset/Cold start vector
     reti            ;External Intr0 vector
     reti            ;External Intr1 vector



;**********************************************************************
;************* M A I N   A P P L I C A T I O N   C O D E  *************
;**********************************************************************

RESET:

    sbi VPORTA_DIR, 7		; set PA7 = output.                   
    sbi VPORTA_OUT, 7		; set /SS of DOG LCD = 1 (Deselected)

    rcall init_lcd_dog    ; init display, using SPI serial interface
    rcall clr_dsp_buffs   ; clear all three SRAM memory buffer lines

   rcall update_lcd_dog		;display data in memory buffer on LCD

   rcall test_lcd

	;breakpoint followin instr. to see blanked LCD and messages in buffer
   rcall update_lcd_dog		;breakpoint here to see blanked LCD

   // after 4 seconds 
   ldi r20, 100
   delay_loop:
   rcall delay_4s
   dec r20
   brne delay_loop

   rcall clr_dsp_buffs   ; clear all three SRAM memory buffer lines

   rcall update_lcd_dog		;display data in memory buffer on LCD

	end_loop:		;infinite loop, program's task is complete
	rjmp end_loop





;---------------------------- SUBROUTINES ----------------------------


;====================================
.include "lcd_dog_asm_driver_avr128.inc"  ; LCD DOG init/update procedures.
;====================================


;************************
;NAME:      clr_dsp_buffs
;FUNCTION:  Initializes dsp_buffers 1, 2, and 3 with blanks (0x20)
;ASSUMES:   Three CONTIGUOUS 16-byte dram based buffers named
;           dsp_buff_1, dsp_buff_2, dsp_buff_3.
;RETURNS:   nothing.
;MODIFIES:  r25,r26, Z-ptr
;CALLS:     none
;CALLED BY: main application and diagnostics
;********************************************************************
clr_dsp_buffs:
     ldi R25, 48               ; load total length of both buffer.
     ldi R26, ' '              ; load blank/space into R26.
     ldi ZH, high (dsp_buff_1) ; Load ZH and ZL as a pointer to 1st
     ldi ZL, low (dsp_buff_1)  ; byte of buffer for line 1.
   
    ;set DDRAM address to 1st position of first line.
store_bytes:
     st  Z+, R26       ; store ' ' into 1st/next buffer byte and
                       ; auto inc ptr to next location.
     dec  R25          ; 
     brne store_bytes  ; cont until r25=0, all bytes written.
     ret


;********************************************************************
; test_lcd

test_lcd:
	ldi XH, high (dsp_buff_1) ; Load ZH and ZL as a pointer to 1st
    ldi XL, low (dsp_buff_1)  ; byte of buffer for line 1.
	ldi r16, 0x30
	ldi r17, 48

	loop:
		st X+, r16
		inc r16

		cpi r16, 0x39
		breq jump_ascii

		cpi r16, 0x7A
		breq jump_ascii_2

		dec r17
		brne loop
		ret

	jump_ascii:
		ldi r16, 0x61
		rjmp loop

	jump_ascii_2:
		ldi r16, 0x41
		rjmp loop



delay_4s:
ldi r18, 255
	outer_loop:
		ldi r17, 255
		inner_loop:
			dec r17
		brne inner_loop
	dec r18
	brne outer_loop

	ret

;	sbic VPORTE_IN, 2
;rjmp wait_for_0_delay_after	;skips this line if PE0 is 0


;	cbi VPORTE_OUT, 1
;	sbi VPORTE_OUT, 1

;	rjmp wait_for_1	;go back to start

;*******************
;NAME:      load_msg
;FUNCTION:  Loads a predefined string msg into a specified diplay
;           buffer.
;ASSUMES:   Z = offset of message to be loaded. Msg format is 
;           defined below.
;RETURNS:   nothing.
;MODIFIES:  r16, Y, Z
;CALLS:     nothing
;CALLED BY:  
;********************************************************************
; Message structure:
;   label:  .db <buff num>, <text string/message>, <end of string>
;
; Message examples (also see Messages at the end of this file/module):
;   msg_1: .db 1,"First Message ", 0   ; loads msg into buff 1, eom=0
;   msg_2: .db 1,"Another message ", 0 ; loads msg into buff 1, eom=0
;
; Notes: 
;   a) The 1st number indicates which buffer to load (either 1, 2, or 3).
;   b) The last number (zero) is an 'end of string' indicator.
;   c) Y = ptr to disp_buffer
;      Z = ptr to message (passed to subroutine)
;********************************************************************
load_msg:
     ldi YH, high (dsp_buff_1) ; Load YH and YL as a pointer to 1st
     ldi YL, low (dsp_buff_1)  ; byte of dsp_buff_1 (Note - assuming 
                               ; (dsp_buff_1 for now).
     lpm R16, Z+               ; get dsply buff number (1st byte of msg).
     cpi r16, 1                ; if equal to '1', ptr already setup.
     breq get_msg_byte         ; jump and start message load.
     adiw YH:YL, 16            ; else set ptr to dsp buff 2.
     cpi r16, 2                ; if equal to '2', ptr now setup.
     breq get_msg_byte         ; jump and start message load.
     adiw YH:YL, 16            ; else set ptr to dsp buff 2.
        
get_msg_byte:
     lpm R16, Z+               ; get next byte of msg and see if '0'.        
     cpi R16, 0                ; if equal to '0', end of message reached.
     breq msg_loaded           ; jump and stop message loading operation.
     st Y+, R16                ; else, store next byte of msg in buffer.
     rjmp get_msg_byte         ; jump back and continue...
msg_loaded:
     ret

;***** END OF FILE ******
