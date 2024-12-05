#include <xc.inc>
    
global  DHT22_Setup, DHT22_Read, delay_short, hum_data, temp_data, checksum
extrn   LCD_delay_ms         ; External delay function from LCD.s

psect	udata_acs   ; reserve data space in access RAM
counter:        ds 1         ; Reserve one byte for a counter variable
delay_count:    ds 1         ; Reserve one byte for counter in the delay routine
temp_data:      ds 2         ; Reserve two bytes for temperature data (MSB, LSB)
hum_data:       ds 2         ; Reserve two bytes for humidity data (MSB, LSB)
checksum:       ds 1         ; Reserve one byte for checksum

psect	DHT22_code,class=CODE

; ****** DHT22 Setup Subroutine **********************************
DHT22_Setup:    
    banksel PADCFG1
    bsf     RJPU               ; Enable pull-ups on PORTJ
    banksel 0
    setf    TRISJ              ; Set all pins of PORTJ as inputs
    return

; ****** DHT22 Read Subroutine ***********************************
DHT22_Read:
    ; Initialize the sensor
    bcf     TRISJ, 0, A        ; Set RJ0 as output
    bcf     LATJ, 0, A         ; Pull data line low
    movlw   18                 ; Wait at least 18ms
    call    LCD_delay_ms        ; Use LCD delay for 18ms
    bsf     TRISJ, 0, A        ; Set RJ0 as input
    nop
    nop

    ; Wait for sensor response
    btfss   PORTJ, 0, A        ; Wait for the line to go low
    bra     $-1
    btfsc   PORTJ, 0, A        ; Wait for the line to go high
    bra     $-1   
    btfss   PORTJ, 0, A        ; Wait for the line to go low again
    bra     $-1

    ; Read 40 bits of data (5 bytes: Humidity MSB/LSB, Temp MSB/LSB, Checksum)
    movlw   5                  ; 5 bytes to read
    movwf   counter, A         ; Initialize counter for bytes
    clrf    temp_data, A       ; Clear temperature data
    clrf    temp_data+1, A
    clrf    hum_data, A        ; Clear humidity data
    clrf    hum_data+1, A
    clrf    checksum, A        ; Clear checksum

Read_Byte:
    movlw   8                  ; 8 bits per byte
    movwf   delay_count, A     ; Counter for bits
Read_Bit_Loop:
    btfss   PORTJ, 0, A        ; Wait for the line to go high
    bra     $-1                ; Stay in loop until high
    call    delay_short        ; Wait for 30us
    btfsc   PORTJ, 0, A        ; If the line is still high, it’s a 1
    bsf     temp_data+1, 7, A  ; Store the bit
    btfss   PORTJ, 0, A        ; Wait for the line to go low
    bra     $-1                ; Stay in loop until low
    rlcf    temp_data+1, F, A  ; Rotate left through carry
    decfsz  delay_count, A     ; Decrement bit counter
    bra     Read_Bit_Loop      ; Repeat for the next bit

    ; Store the byte in appropriate register
    movf    counter, W
    sublw   1
    btfss   STATUS, Z
    bra     Store_Byte_Humidity
    sublw   2
    btfss   STATUS, Z
    bra     Store_Byte_Temperature
    movf    temp_data+1, W, A
    movwf   checksum, A        ; Last byte is the checksum
    bra     Next_Byte

Store_Byte_Humidity:
    movf    temp_data+1, W, A
    movwf   hum_data+1, A      ; Store in LSB of humidity
    bra     Next_Byte

Store_Byte_Temperature:
    movf    temp_data+1, W, A
    movwf   temp_data+1, A     ; Store in LSB of temperature
    bra     Next_Byte

Next_Byte:
    decfsz  counter, A
    bra     Read_Byte          ; Continue reading next byte
    return

; ****** Short Delay Subroutine **********************************
delay_short:
    nop
    nop
    nop
    nop
    return

    end









#include <xc.inc>

global  myTable, myTable_l, myTable2, myTable2_l
extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_line2
extrn   DHT22_Setup, DHT22_Read, Convert_To_String ; Added external reference to Convert_To_String
extrn   hum_data, temp_data

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
myTable:   
	db	'T','e','m','p',':',' ',0x0a ; message, plus carriage return
	myTable_l   EQU	6	; length of data

myTable2:   
        db  'H','u','m',':',' ',0x0a ; message, plus carriage return
        myTable2_l  EQU 5  ; length of data
	align	2
	
psect	code, abs	
rst: 	org 0x0
 	goto	setup

setup:	
	call	DHT22_Setup
	call	UART_Setup
	call	LCD_Setup
	goto	start
	
start:  
    call    DHT22_Read         ; Read temperature and humidity from the sensor
    
    ; Convert and display temperature
    lfsr    0, temp_data
    movf    POSTINC0, W
    call    Convert_To_String  ; Convert temperature to string in myArray
    movlw   myTable_l
    lfsr    2, myArray
    call    LCD_Write_Message
    call    LCD_line2          ; Move to next line
    
    ; Convert and display humidity
    lfsr    0, hum_data
    movf    POSTINC0, W
    call    Convert_To_String  ; Convert humidity to string in myArray
    movlw   myTable2_l
    lfsr    2, myArray
    call    LCD_Write_Message

    goto    start              ; Loop forever

    end

