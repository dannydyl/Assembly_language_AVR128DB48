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

       rcall start

    // keypad subroutine
	//ldi r19, 48
    check_press:
        wait_for_1:
	    sbis VPORTB_IN, 5	;wait for PB5 being 1
        rjmp wait_for_1		;skip this line if PE0 is 1
        dec r19     // chekcing if all character is full
		
        breq reset_pointer

    rjmp output


	end_loop:		;infinite loop, program's task is complete
	rjmp end_loop





;---------------------------- SUBROUTINES ----------------------------

line1_testmessage: .db 1, "Test Message 001", 0  ; message for line #1.

;********************************************************************
; keypad subroutine

table: .db $31, $32, $33, $46, $34, $35, $36, $45, $37, $38, $39, $44, $41, $30, $42, $43


output:
in r18, VPORTC_IN	// gets the input from DIP switch and keypad

lsr r18		// shifting  to right 4 bits
lsr r18
lsr r18
lsr r18

// lookup table from lecture
lookup:
	ldi r16, 0x00
	ldi ZH, high (table*2)
	ldi ZL, low (table*2)
	ldi r16, $00
	add ZL, r18	
	adc ZH, r16
	lpm r18, Z

    st X+, r18  // storing into SRAM buffer



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

    rcall update_lcd_dog    // display

rjmp check_press	// go back to the start

reset_pointer:
    ldi r19, 49

    ldi XH, high (dsp_buff_1) ; Load ZH and ZL as a pointer to 1st
    ldi XL, low (dsp_buff_1)  ; byte of buffer for line 1.

	sbiw XH:XL, $0001   ; decrement the pointer

    rjmp output


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
; start subroutine

start:
    sbi VPORTA_DIR, 4    //MOSI output

    sbi VPORTB_DIR, 4    // clear flip flop
	cbi VPORTB_OUT, 4
	sbi VPORTB_OUT, 4	// clear = 1 

    ; keypad input
    cbi VPORTC_DIR, 7
    cbi VPORTC_DIR, 6
    cbi VPORTC_DIR, 5
    cbi VPORTC_DIR, 4

    cbi VPORTB_DIR, 5    // check if the keypad is pressed

    ldi XH, high (dsp_buff_1) ; Load ZH and ZL as a pointer to 1st
    ldi XL, low (dsp_buff_1)  ; byte of buffer for line 1.

	sbiw XH:XL, $0001   ; decrement the pointer

    ldi r19, 50     // check if all character is full
	ret

;====================================
.include "lcd_dog_asm_driver_avr128.inc"  ; LCD DOG init/update procedures.
;====================================

;***** END OF FILE ******