#include <xc.inc>
    
global  DHT22_Read, Read_Byte, Read_Bit, delay_short, hum_data, temp_data

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
temp_data:  ds 2    ; reserve two bytes for temperature data
hum_data:   ds 2    ; reserve two bytes for humidity data
    
psect	DHT22_code,class=CODE
    ; ******* DHT22 Read Subroutine *********************************
DHT22_Read:
    ; Initialize the sensor
    bcf     TRISH, 0, A       ; Set RH0 as output
    bcf     LATH, 0, A       ; Pull data line low
    movlw   0x12           ; Wait at least 18ms
    movwf   delay_count, A
    call    delay
    bsf     LATH, 0, A         ; Pull data line high
    bsf     TRISH, 0, A       ; Set RH0 as input
    nop
    nop

    ; Wait for sensor response
    btfss   PORTH, 0, A         ; Wait for the line to go low
    bra     $-1
    btfsc   PORTH, 0, A      ; Wait for the line to go high
    bra     $-1
    btfss   PORTH, 0, A      ; Wait for the line to go low again
    bra     $-1

    ; Read 40 bits of data (5 bytes)
    movlw   5                ; 5 bytes to read
    movwf   counter, A
    clrf    temp_data , A       ; Clear temperature data
    clrf    temp_data+1, A
    clrf    hum_data, A         ; Clear humidity data
    clrf    hum_data+1, A

Read_Byte:
    movlw   8                ; 8 bits per byte
    movwf   delay_count, A

Read_Bit:
    btfss   PORTH, 0, A         ; Wait for the line to go high
    bra     $-1
    call    delay_short    ; Wait for 30us
    btfsc   PORTH, 0, A         ; If the line is still high, it's a 1
    bsf     hum_data+1, 7, A    ; Store the bit
    btfss   PORTH, 0, A         ; Wait for the line to go low
    bra     $-1
    rlcf    hum_data+1, F, A    ; Rotate left through carry
    decfsz  delay_count, A
    bra     Read_Bit

    decfsz  counter, A
    bra     Read_Byte

    return

delay_short:
    nop
    nop
    nop
    nop
    return
    
delay:	
    decfsz	delay_count, A	; decrement until zero
    bra	delay
	
    end
    
