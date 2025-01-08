#include <xc.inc>

global  update
extrn	UART_Transmit_Message, UART_Transmit_Byte
extrn	LCD_Write_Message, LCD_line1, LCD_line2, LCD_Send_Byte_D
extrn   DHT22_Read, data_buffer
extrn   HexToDec, temp, temph
extrn   myTable, myTable_l, myTable2, myTable2_l, counter, myArray
    

    
psect Update_data, class=CODE
    
update:	    call	DHT22_Read      ; read data from DHT22 sensor
	    lfsr	0, myArray	; Load FSR0 with address in RAM	
	    movlw	low highword(myTable)	; address of data in PM
	    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	    movlw	high(myTable)	; address of data in PM
	    movwf	TBLPTRH, A		; load high byte to TBLPTRH
	    movlw	low(myTable)	; address of data in PM
	    movwf	TBLPTRL, A		; load low byte to TBLPTRL
	    movlw	(myTable_l )	; bytes to read
	    movwf 	counter, A		; our counter register
loop:	    tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	    movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	    decfsz	counter, A		; count down to zero
	    bra	loop		; keep going until finished
	    ;movlw	myTable_l	; output message to UART
	    ;addlw	0xff		; don't send the final carriage return
	    ;lfsr	2, myArray
	    ;call	UART_Transmit_Message
	    ;Write temp to LCD
	    movlw	myTable_l	; output message to LCD
	    addlw	0xff		; don't send the final carriage return to LCD
	    lfsr	2, myArray      ;Load address of myArray
	    call	LCD_Write_Message ;Write temp label + value to LCD
	    movff	data_buffer+2, temph
	    movff	data_buffer+3, temp
	    call	HexToDec
	    movlw   '^'              
	    call    LCD_Send_Byte_D
	    movlw   'C'              
	    call    LCD_Send_Byte_D
	    call	LCD_line2       ;Move to next line for humidity
	    movlw	';'
	    call	UART_Transmit_Byte

	    ;Display
	    lfsr	0, myArray	; Load FSR0 with address in RAM	
	    movlw	low highword(myTable2)	; address of data in PM
	    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	    movlw	high(myTable2)	; address of data in PM
	    movwf	TBLPTRH, A		; load high byte to TBLPTRH
	    movlw	low(myTable2)	; address of data in PM
	    movwf	TBLPTRL, A		; load low byte to TBLPTRL
	    movlw	(myTable2_l )	; bytes to read
	    movwf 	counter, A		; our counter register
loop2:	    tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	    movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	    decfsz	counter, A		; count down to zero
	    bra		loop2		; keep going until finished
 	    ;movlw	myTable2_l	; output message to UART
 	    ;addlw	0xff		; don't send the final carriage return
 	    ;lfsr	2, myArray
 	    ;call	UART_Transmit_Message

	    movlw	myTable2_l	; output message to LCD
	    addlw	0xff		; don't send the final carriage return to LCD
	    lfsr	2, myArray
	    call	LCD_Write_Message
	    movff	data_buffer, temph
	    movff	data_buffer+1, temp
	    call	HexToDec
	    movlw	'%'              
	    call	LCD_Send_Byte_D
	    call	LCD_line1       ;Move to next line for humidity
	    movlw	';'
	    call	UART_Transmit_Byte
	    movlw	'1'
	    btfss	LATC, 0, A
	    movlw	'0'
	    call	UART_Transmit_Byte
	    movlw	';'
	    call	UART_Transmit_Byte
	    movlw	'1'
	    btfss	LATC, 1, A
	    movlw	'0'
	    call	UART_Transmit_Byte
	    movlw	';'
	    call	UART_Transmit_Byte
	    movlw	'1'
	    btfss	LATC, 2, A
	    movlw	'0'
	    call	UART_Transmit_Byte
	    movlw	0x0a
	    call	UART_Transmit_Byte
	    return
	end
