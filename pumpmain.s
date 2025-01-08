#include <xc.inc>
   
extrn heater_setup, heater_on, heater_off, thirty_seconds, five_minute, delayf, one_min
extrn fan_on, fan_off, pump_on, pump_off
extrn LCD_delay_ms, UART_Transmit_Byte
extrn maindisplay_setup, update

psect	udata_acs
	loopcnt: ds 1
	step_cnt: ds 1
    
psect	code,abs
rst: 	org 0x0			;i believe this means start reading from 0x0
 	goto	setup
setup:	call	heater_setup
	call	maindisplay_setup
	goto	start
start:	
	movlw	'0'
	movwf	step_cnt
	;call	thirty_seconds
	call	heater_off	; step 0, heater off, fan on
	call	fan_on
	call	loop5

	call	heater_on	; step 1, heater on, fan off
	call	fan_off
	call	loop5
	
	call	heater_off	; step 2, heater off, fan on
	call	fan_on
	call	loop5
	
	call	heater_on	; step 3, heater on, fan on
	call	fan_on
	call	loop5
	
	call	heater_off	; step 4, heater off, fan off, squirt water
	call	fan_off
	call	pump_on
	call	delayf
	call	pump_off
	call	loop5
	
	call	heater_off	; step 5, heater off, fan on
	call	fan_on
	call	loop5
	
	call	heater_on	; step 6, heater on, fan off
	call	fan_off
	call	loop5
	
	call	heater_off	; step 7, heater off, fan on
	call	fan_on
	call	loop5
	
	call	heater_on	; step 8, heater on, fan on
	call	fan_on
	call	loop5

;	call	delayf
;	call	pump_on
;	call	delayf
;	call	pump_off
;	call	update
;	call	delayf
;	;call	five_minute
;	;call	thirty_seconds
;	call	heater_off
;	call	update
;	;call	five_minute
;	call	delayf
;	;call	thirty_seconds
	goto	start
	
loop5:	
	movlw	5
	movwf	loopcnt, A
	incf	step_cnt, F
loop:	movf	step_cnt, W
	call	UART_Transmit_Byte
	movlw	';'
	call	UART_Transmit_Byte
	call	update
	call	one_min
	decfsz	loopcnt, A
	bra	loop
	return
	
	end	rst
    

