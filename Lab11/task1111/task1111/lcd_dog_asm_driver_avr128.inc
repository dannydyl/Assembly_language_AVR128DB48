;
; lcd_avr128_driver_asm.asm
;
; Created: 10/9/2023 12:33:05 PM
; Author : kshort
;


;**************************************************************** v1.1a
;   AVR128DB48 Version:                PRINT IN LANDSCAPE
;	Revised 10/09/23                     
;   Revised 11/30/18 **** For Lab 10 Fall 18 Only ****
;	
;   This AVR-asm code module is usable as an include file for assembly
;   language and or mixed asm/C application programs.
;
;   This code is designed to be executed on an AVR128DB48.
;
;	Note: Settings may need to be changed in init_lcd_dog subroutine
;	depending on whether the LCD is operated at 3.3 V or 5.0 V, see
;	comments in the subroutine.
;
;*********************************************************************
;
;   This module contains procedures to initialize and update
;   DOG text based LCD display modules, including the EA DOG163M LCD
;   modules configured with three (3) 16 charactors display lines.
;
;   The display module hardware interface uses a write only
;   SPI interface. (See below for more information.)
;
;   The display module software interface uses three (3) 16-byte
;   data (SRAM) based display buffers - One for each line of the display.
;   (See below for more information.)


;
;******************
;
;      Notes:  RS ==>  0 = command regs, 1 = data regs
;             /SS = active low SPI select signal
;
;******************

/*
*
* SPI0 is configured as SPI master.
* Clock rate is set to 250 kHz, 1/16 of the main clock.
* AVR128DB48 will be connected to Microchip DOGM163-A LCD
* PA7 is used to select DOGM163-A LCD.
* 
* SPI clock Polarity/Phase are 1, 1
*
* PA4  MOSI
* PA6  SCK
* PA7  /CS for DOGM163-A LCD
* PA5  MISO ;not used                                                                                                                         
*
* PC0	RS
*
* Tested with Atmel Studio 7
*/

;***  DATA Segment  **************************************************   
.dseg
dsp_buff_1:   .byte 16		;16 byte array for display line 1
dsp_buff_2:   .byte 16		;16 byte array for display line 2
dsp_buff_3:   .byte 16		;16 byte array for display line 3



;***  CODE Segment Subroutines  ************************************
.cseg


;************************
;NAME:        delay_30uS
;ASSUMES:     nothing
;RETURNS:     nothing
;MODIFIES:    R24, SREG
;CALLED BY:   init_dsp
;DESCRIPTION: This procedure will generate a fixed delay of just over
;             30 uS (assuming a 1 MHz clock).
;********************************************************************
delay_30uS:   nop     ; fine tune delay
              nop
              push  r24
              ldi   r24, 0x0f  ; load delay count. //4 added 100923
d30_loop:     dec   r24        ; count down to
              brne  d30_loop   ; zero.
              pop   r24
              ret


;*********************
;NAME:        v_delay
;ASSUMES:     R22, R23 = initial count values defining how many
;             30uS delays will be called. This procedure can generate
;             short delays (r23 = small #) or much longer delays (where
;             R23 value is large).
;RETURNS:     nothing
;MODIFIES:    R22, R23, SREG
;CALLED BY:   init_dsp, plus...
;DESCRIPTION: This procedure will generate a variable delay for a fixed
;             period of time based the values pasted in R24 and R25.
;
;Sample Delays:
;
;             R22  R23  DelayTime
;             ---  ---  ---------
;              1    1   ~65.5 uS
;              0    1   ~14.2 mS
;              0    9   ~130 mS


;**********************************************************************
v_delay:      rcall delay_30uS ; delay for ~30uS
              dec   r22      ; decrement inner loop value, and
              brne  v_delay  ; loop until zero.
              dec   r23      ; decr outer loop count, and loop back
              brne  v_delay  ; to inner loop delay until r23 zero.
              ret


;***********************
;NAME:        delay_40mS
;ASSUMES:     nothing
;RETURNS:     nothing
;MODIFIES:    R22,R23, SREG
;CALLED BY:   init_dsp, ????
;DESCRIPTION: This procedure will generate a fixed delay of just over
;             40 mS.
;********************************************************************
delay_40mS:   ldi   r22,0        ; load inner loop var
              ldi   r23,4       ; load outer loop var
              rcall  v_delay     ; delay
              ret


;************************
;NAME:       init_spi_lcd
;ASSUMES:    MOSI, SCK, and /SS set as output (during program init)
;RETURNS:    nothing
;MODIFIES:   DDRB, SPCR
;CALLED BY:  init_dsp, update
;DESCRITION: init SPI port for command and data writes to LCD via SPI
;********************************************************************
init_spi_lcd:
		// Msb first, CPOL = 1, CPHA = 1	
		// Use PA7 of AVR128DB48 as software controlled select for DOG
 		push r16
		sbi VPORTA_DIR, 7      // make PA7 an output
		sbi VPORTA_OUT, 7      // make PA7 a 1

		sbi VPORTA_DIR, 4      // make PA4 (MOSI) an output
		cbi VPORTA_OUT, 4      // make PA4 a 0

		sbi VPORTA_DIR, 6      // make PA6 (SCK) an output
		sbi VPORTA_OUT, 6      // make PA6 a 0
		
		//Need to make /SS an output or else if it is input and reads 0,
		//it will clear the master flag
		sbi VPORTA_DIR, 7      // make PA7 (/SS) an output
		sbi VPORTA_OUT, 7      // make PA7 a 1
		
		sbi VPORTC_DIR, 0      // make PC0 an output
		sbi VPORTC_OUT, 0      // make PC0 a 1	for data
		
		// Configure SPI0 master, enabled, CLK_PER / 4
		ldi r16, (SPI_MASTER_bm | SPI_ENABLE_bm | SPI_PRESC_DIV16_gc)
		sts SPI0_CTRLA, r16
		ldi r16, (SPI_MODE_3_gc | SPI_SSD_bm)
		sts SPI0_CTRLB, r16    //slave select disable, mode 3

		ldi r16,'U'
		sbi VPORTC_OUT, 0    ; set PC0 = RS = 1 = data.
	    cbi VPORTA_OUT, 7    ; clr PA7 = LCD selected.
		nop
		nop
		nop
		nop
		sts SPI0_DATA,r16      ; write data to SPI port.
wait_transmit_init:
		lds r16, SPI0_INTFLAGS    ; read status reg
		sbrs r16, 7	; IF normal mode   ; if SPIF_IF_bp  = 0 wait
		rjmp wait_transmit_init
		sbi VPORTA_OUT, 7   ; set PA7 = LCD deselected

 		pop r16
		ret


;********************************
;NAME:       lcd_spi_transmit_CMD
;ASSUMES:    r16 = byte for LCD.
;            SPI port is configured.
;RETURNS:    nothing
;MODIFIES:   R16, PortB, SPCR
;CALLED BY:  init_dsp, update
;DESCRITION: outputs a byte passed in r16 via SPI port. Waits for data
;            to be written by spi port before continuing.
; modified for AVR128DB48 100923
;*********************************************************************

lcd_spi_transmit_CMD:
     push r16          ; save command, need r16.

wait_transmit0:		//added 100923
     lds r16, SPI0_INTFLAGS    ; read status reg
     sbrs r16, 7	; IF normal mode   ; if IF  = 0 wait
     rjmp wait_transmit0
	 lds r16, SPI0_DATA		;clear SPIF0

     cbi   VPORTC_OUT, 0    ; clr PC0 = RS = 0 = command.
     cbi   VPORTA_OUT, 7    ; clr PA7 = /SS = selected.
     pop r16           ; restore command
	 nop
	 nop
	 nop
	 nop
     sts SPI0_DATA,r16      ; write data to SPI port.

     ;Wait for transmission complete SPIF_IF = 1
wait_transmit1:
     lds r16, SPI0_INTFLAGS    ; read status reg
     sbrs r16, 7	; IF normal mode   ; if SPIF_IF_bp  = 0 wait
     rjmp wait_transmit1

     sbi   VPORTA_OUT, 7   ; set PA7 = /SS = deselected
     ret



;*********************************
;NAME:       lcd_spi_transmit_DATA
;ASSUMES:    r16 = byte to transmit to LCD.
;            SPI port is configured.
;RETURNS:    nothing
;MODIFIES:   R16, SPCR
;CALLED BY:  init_dsp, update
;DESCRITION: outputs a byte passed in r16 via SPI port. Waits for
;            data to be written by spi port before continuing.
;*****************************************************************
lcd_spi_transmit_DATA:
     push r16          ; save command, need r16.

wait_transmit2:		//added 100923
     lds r16, SPI0_INTFLAGS    ; read status reg
     sbrs r16, 7	; IF normal mode   ; if IF  = 0 wait
     rjmp wait_transmit2
	 lds r16, SPI0_DATA		;clear SPIF0 (kls102817)

     sbi   VPORTC_OUT, 0    ; set PC0 = RS = 1 = data.
     cbi   VPORTA_OUT, 7    ; clr PA7 = /SS = selected.
	 pop r16
 	 nop
	 nop
	 nop
	 nop
     sts SPI0_DATA,r16      ; write data to SPI port.

     ;Wait for transmission complete
wait_transmit3:
     lds r16, SPI0_INTFLAGS     ; read status reg
     sbrs r16, 7	; IF nomral mode   ; if bit 7  = 0 wait
     rjmp wait_transmit3

     sbi   VPORTA_OUT, 7   ; set PA7 = /SS = deselected
     ret



;************************
;NAME:       init_lcd_dog
;ASSUMES:    nothing
;RETURNS:    nothing
;MODIFIES:   R16, R17
;CALLED BY:  main application
;DESCRITION: inits DOG module LCD display for SPI (serial) operation.
;NOTE:  Can be used as is with MCU clock speeds of 4MHz or less.
;********************************************************************
; public __version_1 void init_dsp(void)
init_lcd_dog:
       rcall init_spi_lcd   ; init SPI port for DOG LCD.

start_dly_40ms:
       rcall  delay_40mS    ; startup delay.

func_set1:
       ldi    r16,0x39      ; send fuction set #1
       rcall  lcd_spi_transmit_CMD   ;
       rcall  delay_30uS    ; delay for command to be processed

func_set2:
       ldi    r16,0x39      ; send fuction set #2
       rcall  lcd_spi_transmit_CMD
       rcall  delay_30uS    ; delay for command to be processed

bias_set:
       ldi    r16,0x1E      ; set bias value.
       rcall  lcd_spi_transmit_CMD
       rcall  delay_30uS    ;

contrast_set:
       ldi    r16,0x7F      ;~ 77 for 5V
							;~ 7F for 3.3V  
       rcall  lcd_spi_transmit_CMD
       rcall  delay_30uS    ; 

power_ctrl:
       ldi    r16,0x55      ;~ 0x50 nominal for 5V
							;~ 0x55 for 3.3V (delicate adjustment). 
       rcall  lcd_spi_transmit_CMD
       rcall  delay_30uS    ;

follower_ctrl:
       ldi    r16,0x6C      ; follower mode on... 
       rcall  lcd_spi_transmit_CMD
       rcall  delay_40mS    ;
	     rcall  delay_40mS    ;
	     rcall  delay_40mS    ;
		 rcall  delay_40mS    ;
		 rcall  delay_40mS    ;

display_on:
       ldi    r16,0x0c      ; display on, cursor off, blink off
       rcall  lcd_spi_transmit_CMD
       rcall  delay_30uS    ; 

entry_mode:
       ldi    r16,0x06      ; clear display, cursor home
       rcall  lcd_spi_transmit_CMD;
       rcall  delay_30uS    ;
       ret

clr_display:
       ldi    r16,0x01      ; clear display, cursor home
       rcall  lcd_spi_transmit_CMD
       rcall  delay_30uS    ;



;**************************
;NAME:       update_lcd_dog
;ASSUMES:    display buffers loaded with display data
;RETURNS:    nothing
;MODIFIES:   R16,R20,R30,R31,SREG
;
;DESCRITION: Updates the LCD display lines 1, 2, and 3, using the
;  contents of dsp_buff_1, dsp_buff_2, and dsp_buff_3, respectively.
;*******************************************************************
; public __version_1 void update_dsp_dog (void)
update_lcd_dog:
       rcall init_spi_lcd    ; init SPI port for LCD.
       ldi   r20,16          ; init 'chars per line' counter.
       push  r20             ; save for later used.

       ;send line 1 to the LCD module.
wr_line1:     
       ldi   ZH, high (dsp_buff_1)  ; init ptr to line 1 display buffer.
       ldi   ZL, low (dsp_buff_1)   ;
snd_ddram_addr:
       ldi   r16,0x80             ; init DDRAM addr-ctr 
       rcall lcd_spi_transmit_CMD ; 
       rcall delay_30uS
snd_buff_1:
       ld    r16, Z+
       rcall lcd_spi_transmit_DATA
       rcall delay_30uS
       dec   r20
       brne  snd_buff_1

       ;send line 2 to the LCD module.
init_for_buff_2:
       pop   r20     ; reload r20 = chars per line counter
       push  r20     ; save for line 3
wr_line2:
       ldi   ZH, high (dsp_buff_2)  ; init ptr to line 2 display buffer.
       ldi   ZL, low (dsp_buff_2)
snd_ddram_addr2:
       ldi   r16,0x90               ; init DDRAM addr-ctr 
       rcall lcd_spi_transmit_CMD           ;  
       rcall delay_30uS
snd_buff_2:
       ld    r16, Z+
       rcall lcd_spi_transmit_DATA
       rcall delay_30uS
       dec   r20
       brne  snd_buff_2

       ;send line 3 to the LCD module.
init_for_buff_3:
       pop   r20     ; reload r20 = chars per line counter
wr_line3:
       ldi   ZH, high (dsp_buff_3)  ; init ptr to line 2 display buffer.
       ldi   ZL, low (dsp_buff_3)
snd_ddram_addr3:
       ldi   r16,0xA0               ; init DDRAM addr-ctr 
       rcall lcd_spi_transmit_CMD           ;  
       rcall delay_30uS
snd_buff_3:
       ld    r16, Z+
       rcall lcd_spi_transmit_DATA
       rcall delay_30uS
       dec   r20
       brne  snd_buff_3
       ret


;******* End Of Include Module *********************************
