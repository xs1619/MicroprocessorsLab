#include <xc.inc>

global  maindisplay_setup, maindisplay_start, myTable, myTable_l, myTable2, myTable2_l, counter, myArray
extrn	UART_Setup, UART_Transmit_Message, UART_Transmit_Byte  
extrn	LCD_Setup, LCD_Write_Message, LCD_line1, LCD_line2, LCD_Send_Byte_D
extrn   DHT22_Setup
    ;, DHT22_Read, Read_Byte, delay_short, Read_Bit, data_buffer
extrn   HexToDec, Divide_Loop, Subtract, Division
extrn	fan_on, fan_off
extrn	heater_on, heater_off, heater_setup
extrn	thirty_seconds, five_minute, delayf, one_min
extrn	update

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable

    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
;	 ******* myTable, data in programme memory, and its length *****
myTable:   
	db	'T','e','m','p','(',')',':',0x0a ; message, plus carriage return
	myTable_l   EQU	8	; length of data
	
myTable2:   
        db  'H','u','m','i','d','i','t','y',':',0x0a ; message, plus carriage return
        myTable2_l  EQU 10  ; length of data
	align	2
	
psect	maindisplay_code, class=CODE
	
	; ******* Programme FLASH read Setup Code ***********************
maindisplay_setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	DHT22_Setup
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	return
	
	; ******* Main programme ****************************************
maindisplay_start:	
	call	fan_on
	call	update
	call	one_min
	call	update
	call	fan_off
	call	heater_on
	call	one_min
	call	update
	call	heater_off
	return
	
	
;	goto    start
	

	end	
	

