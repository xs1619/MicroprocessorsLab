#include <xc.inc>

global  myTable, myTable_l, myTable2, myTable2_l
extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_line2
extrn   DHT22_Setup, DHT22_Read, Read_Byte, delay_short, hum_data, temp_data, Read_Bit
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:   
	db	'T','e','m','p','(',')',':',0x0a ; message, plus carriage return
	myTable_l   EQU	8	; length of data
	
myTable2:   
        db  'H','u','m','i','d','i','t','y',':',0x0a ; message, plus carriage return
        myTable2_l  EQU 10  ; length of data
	align	2
	
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	DHT22_Setup
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	goto	start
	
	; ******* Main programme ****************************************
start: 	call    DHT22_Read      ; read data from DHT22 sensor
    
        lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	(myTable_l )	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable_l	; output message to LCD
	addlw	0xff		; don't s
; Convert_To_String Subroutine
Convert_To_String:
    ; Converts a 16-bit binary number in WREG to an ASCII string.
    ; Input: Number in WREG, Output: ASCII string in myArray starting at FSR0.
    movwf temp_data, A         ; Store the input number temporarily
    clrf myArray, A           ; Clear the array for the result
    movlw 10                  ; Divisor for decimal conversion
    movwf delay_count, A      ; Use delay_count as a divisor register

    ; Extract digits and convert to ASCII
    movlw 3                  ; Initialize digit count (e.g., 3 digits max for display)
loop_div:
    movf temp_data, W, A      ; Load the current number
    subwf delay_count, W      ; Subtract divisor
    btfsc STATUS, C           ; If carry set, division succeeded
    bra loop_div              ; Repeat the division
    movlw '0'                 ; ASCII offset for digits
    addwf temp_data, F, A     ; Add offset to remainder
    movwf POSTINC0, A         ; Store the result in myArray
    decfsz delay_count, A
    bra loop_div

    return                    ; Return to caller

; Main loop modification to display results dynamically on the LCD
start:
    call DHT22_Read           ; Read temperature and humidity from the sensor

    ; Construct temperature message dynamically
    movlw 'T'                 ; "Temp: "
    movwf POSTINC0, A
    movlw 'e'
    movwf POSTINC0, A
    movlw 'm'
    movwf POSTINC0, A
    movlw 'p'
    movwf POSTINC0, A
    movlw ':'
    movwf POSTINC0, A

    movf temp_data, W, A       ; Convert temperature to string
    call Convert_To_String

    movlw 0x00                ; Null terminator for LCD
    movwf POSTINC0, A

    ; Display temperature on the LCD
    lfsr 2, myArray
    call LCD_Write_Message

    call LCD_line2            ; Move to the second line of the LCD

    ; Construct humidity message dynamically
    movlw 'H'                 ; "Humidity: "
    movwf POSTINC0, A
    movlw 'u'
    movwf POSTINC0, A
    movlw 'm'
    movwf POSTINC0, A
    movlw 'i'
    movwf POSTINC0, A
    movlw 'd'
    movwf POSTINC0, A
    movlw 'i'
    movwf POSTINC0, A
    movlw 't'
    movwf POSTINC0, A
    movlw 'y'
    movwf POSTINC0, A
    movlw ':'
    movwf POSTINC0, A

    movf hum_data, W, A        ; Convert humidity to string
    call Convert_To_String

    movlw 0x00                ; Null terminator for LCD
    movwf POSTINC0, A

    ; Display humidity on the LCD
    lfsr 2, myArray
    call LCD_Write_Message

end
 the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	
	call	LCD_line2

	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable2)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable2)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable2)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	(myTable2_l )	; bytes to read
	movwf 	counter, A		; our counter register

loop2: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop2		; keep going until finished
		
	movlw	myTable2_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable2_l	; output message to LCD
	addlw	0xff		; don't s
; Convert_To_String Subroutine
Convert_To_String:
    ; Converts a 16-bit binary number in WREG to an ASCII string.
    ; Input: Number in WREG, Output: ASCII string in myArray starting at FSR0.
    movwf temp_data, A         ; Store the input number temporarily
    clrf myArray, A           ; Clear the array for the result
    movlw 10                  ; Divisor for decimal conversion
    movwf delay_count, A      ; Use delay_count as a divisor register

    ; Extract digits and convert to ASCII
    movlw 3                  ; Initialize digit count (e.g., 3 digits max for display)
loop_div:
    movf temp_data, W, A      ; Load the current number
    subwf delay_count, W      ; Subtract divisor
    btfsc STATUS, C           ; If carry set, division succeeded
    bra loop_div              ; Repeat the division
    movlw '0'                 ; ASCII offset for digits
    addwf temp_data, F, A     ; Add offset to remainder
    movwf POSTINC0, A         ; Store the result in myArray
    decfsz delay_count, A
    bra loop_div

    return                    ; Return to caller

; Main loop modification to display results dynamically on the LCD
start:
    call DHT22_Read           ; Read temperature and humidity from the sensor

    ; Construct temperature message dynamically
    movlw 'T'                 ; "Temp: "
    movwf POSTINC0, A
    movlw 'e'
    movwf POSTINC0, A
    movlw 'm'
    movwf POSTINC0, A
    movlw 'p'
    movwf POSTINC0, A
    movlw ':'
    movwf POSTINC0, A

    movf temp_data, W, A       ; Convert temperature to string
    call Convert_To_String

    movlw 0x00                ; Null terminator for LCD
    movwf POSTINC0, A

    ; Display temperature on the LCD
    lfsr 2, myArray
    call LCD_Write_Message

    call LCD_line2            ; Move to the second line of the LCD

    ; Construct humidity message dynamically
    movlw 'H'                 ; "Humidity: "
    movwf POSTINC0, A
    movlw 'u'
    movwf POSTINC0, A
    movlw 'm'
    movwf POSTINC0, A
    movlw 'i'
    movwf POSTINC0, A
    movlw 'd'
    movwf POSTINC0, A
    movlw 'i'
    movwf POSTINC0, A
    movlw 't'
    movwf POSTINC0, A
    movlw 'y'
    movwf POSTINC0, A
    movlw ':'
    movwf POSTINC0, A

    movf hum_data, W, A        ; Convert humidity to string
    call Convert_To_String

    movlw 0x00                ; Null terminator for LCD
    movwf POSTINC0, A

    ; Display humidity on the LCD
    lfsr 2, myArray
    call LCD_Write_Message

end
 the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	
	;call	LCD_line2
	
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return 
	;goto $

	
; Convert_To_String Subroutine
Convert_To_String:
    ; Converts a 16-bit binary number in WREG to an ASCII string.
    ; Input: Number in WREG, Output: ASCII string in myArray starting at FSR0.
    movwf temp_data, A         ; Store the input number temporarily
    clrf myArray, A           ; Clear the array for the result
    movlw 10                  ; Divisor for decimal conversion
    movwf delay_count, A      ; Use delay_count as a divisor register

    ; Extract digits and convert to ASCII
    movlw 3                  ; Initialize digit count (e.g., 3 digits max for display)
loop_div:
    movf temp_data, W, A      ; Load the current number
    subwf delay_count, W      ; Subtract divisor
    btfsc STATUS, C           ; If carry set, division succeeded
    bra loop_div              ; Repeat the division
    movlw '0'                 ; ASCII offset for digits
    addwf temp_data, F, A     ; Add offset to remainder
    movwf POSTINC0, A         ; Store the result in myArray
    decfsz delay_count, A
    bra loop_div

    return                    ; Return to caller

; Main loop modification to display results dynamically on the LCD
start:
    call DHT22_Read           ; Read temperature and humidity from the sensor

    ; Construct temperature message dynamically
    movlw 'T'                 ; "Temp: "
    movwf POSTINC0, A
    movlw 'e'
    movwf POSTINC0, A
    movlw 'm'
    movwf POSTINC0, A
    movlw 'p'
    movwf POSTINC0, A
    movlw ':'
    movwf POSTINC0, A

    movf temp_data, W, A       ; Convert temperature to string
    call Convert_To_String

    movlw 0x00                ; Null terminator for LCD
    movwf POSTINC0, A

    ; Display temperature on the LCD
    lfsr 2, myArray
    call LCD_Write_Message

    call LCD_line2            ; Move to the second line of the LCD

    ; Construct humidity message dynamically
    movlw 'H'                 ; "Humidity: "
    movwf POSTINC0, A
    movlw 'u'
    movwf POSTINC0, A
    movlw 'm'
    movwf POSTINC0, A
    movlw 'i'
    movwf POSTINC0, A
    movlw 'd'
    movwf POSTINC0, A
    movlw 'i'
    movwf POSTINC0, A
    movlw 't'
    movwf POSTINC0, A
    movlw 'y'
    movwf POSTINC0, A
    movlw ':'
    movwf POSTINC0, A

    movf hum_data, W, A        ; Convert humidity to string
    call Convert_To_String

    movlw 0x00                ; Null terminator for LCD
    movwf POSTINC0, A

    ; Display humidity on the LCD
    lfsr 2, myArray
    call LCD_Write_Message

end
	rst
	


