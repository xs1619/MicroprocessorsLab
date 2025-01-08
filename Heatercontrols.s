#include <xc.inc>
global heater_setup, heater_on, heater_off, thirty_seconds, five_minute, delayf, one_min
extrn LCD_delay_ms

 psect udata_acs
 sdelaycount: ds 1
 psect	heater_code,class=CODE
 heater_setup:
	;banksel LATB
	movlw   103		; gives 9600 Baud rate (actually 9615)
	movwf   SPBRG1, A	; set baud rate
	clrf    LATC, A	    ;clearing ports
	movlw   00000000B   ;setting all to outputs
 	movwf   TRISC, A	    ;moves moves literal into trisb setting to outputs
	return
 
 heater_on:   
	;bcf	    TRISC, 0, A	    ;supposed to pull the line high
	;bcf	    LATC, 1, A
	movlw	    00000011B
	bsf	    LATC, 1, A
	return
    
    
 heater_off:
	;bcf	    TRISC, 0, A	    ;supposed to pull the line low
	;bcf	    LATC, 0, A
	bcf	    LATC, 1, A	    ;clears bit 0 on portb resulting in a low
	return
	
thirty_seconds:
	movlw	30
	movwf	sdelaycount, A
subbranch:
	movlw	250
	call	LCD_delay_ms
	movlw	250
	call	LCD_delay_ms
	movlw	250
	call	LCD_delay_ms
	movlw	250
	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
;	movlw	143
;	call	LCD_delay_ms
	decfsz sdelaycount, A
	bra subbranch
	return
	
delayf:
	movlw	2
	movwf	sdelaycount, A
subbranc:
	movlw	250
	call	LCD_delay_ms
	movlw	250
	call	LCD_delay_ms
	movlw	250
	call	LCD_delay_ms
	movlw	250
	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
;	movlw	250
;	call	LCD_delay_ms
	decfsz sdelaycount, A
	bra subbranc
	return
	
five_minute:
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    call    thirty_seconds
    return
	
    
one_min:
    call    thirty_seconds
    call    thirty_seconds
    return
    end


