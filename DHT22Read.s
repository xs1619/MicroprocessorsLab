#include <xc.inc>
    
global  DHT22_Setup, DHT22_Read, Read_Byte, delay_short, data_buffer, Read_Bit 
extrn	LCD_delay_ms, LCD_delay_x4us

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
data_buffer:  ds 5    ; reserve five bytes for temperature data
    
psect	DHT22_code,class=CODE
    ; ******* DHT22 Read Subroutine *********************************
DHT22_Setup:    
    banksel PADCFG1
    bsf     RJPU
    banksel 0
    setf    TRISJ    
    return

DHT22_Read:
    ; Initialize the sensor
    movlw   90 
    call    LCD_delay_ms
    bcf     TRISJ, 0, A       ; Set RH0 as output
    bcf     LATJ, 0, A       ; Pull data line low
    movlw   0xff           ; Wait at least 18ms
    ; movwf   delay_count, A
    ; call    delay
    movlw   18
    call    LCD_delay_ms
    ;bsf     LATJ, 0, A         ; Pull data line high
    bsf     TRISJ, 0, A       ; Set RH0 as input
    nop
    nop

    ; Wait for sensor response
    btfss   PORTJ, 0, A         ; Wait for the line to go low
    bra     $-2
    btfsc   PORTJ, 0, A      ; Wait for the line to go high
    bra     $-2   
    btfss   PORTJ, 0, A      ; Wait for the line to go low again
    bra     $-2

    ; Read 40 bits of data (5 bytes)
    movlw   5                ; 5 bytes to read
    movwf   counter, A
    clrf    data_buffer , A       ; Clear buffer data
    ; loop to read 5 bytes
    

Read_Byte:
    movlw   8                ; 8 bits per byte
    movwf   delay_count, A
    ; loop to read 8 bits
    

Read_Bit:
    btfss   PORTJ, 0, A         ; Wait for the line to go high
    bra     $-2
    movlw   8
    call    LCD_delay_x4us    ; Wait for 32us
    btfsc   PORTJ, 0, A         ; If the line is still high, it's a 1
    bsf     data_buffer+4, 0, A    ; Store the bit
    btfss   PORTJ, 0, A         ; Wait for the line to go low
    bra     $-2
    bcf	    CARRY
    rlcf    data_buffer+4, F, A    ; Rotate left through carry
    rlcf    data_buffer+3, F, A    ; Rotate left through carry
    rlcf    data_buffer+2, F, A    ; Rotate left through carry
    rlcf    data_buffer+1, F, A    ; Rotate left through carry
    rlcf    data_buffer, F, A    ; Rotate left through carry
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
    return
    
    end
    