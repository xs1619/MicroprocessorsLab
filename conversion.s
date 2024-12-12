#include <xc.inc>

global  HexToDec, Divide_Loop, Subtract, Division
; Subroutine to convert hexadecimal to decimal

; Variables
hex_temp1    EQU 0x02   ; From main routine
high_nibble1 EQU 0x11
low_nibble1  EQU 0x12
hex_temp2    EQU 0x03
high_nibble2 EQU 0x21
low_nibble2  EQU 0x22
hex_hum1     EQU 0x04
hex_hum2     EQU 0x05 
   
temp         EQU 0x30
result       EQU 0x31
tens         EQU 0x32
units        EQU 0x33
divisor      EQU 0x34
   
HexToDec:
    ;temp
    ;extract high nibble 
    movlw   hex_temp1      ; Load temp(integer) into WREG
    andlw   0xf0
    swapf   WREG, W
    movwf   high_nibble1
    
    ;extract low nibble 
    movlw   hex_temp1      ; Load temp(decimal) into WREG
    andlw   0x0f
    movwf   low_nibble1
    
     ;extract high nibble 
    movlw   hex_temp2      ; Load temp(decimal) into WREG
    andlw   0xf0
    swapf   WREG, W
    movwf   high_nibble2
    
    ;extract low nibble 
    movlw   hex_temp2       ; Load temp(decimal) into WREG
    andlw   0x0f
    movwf   low_nibble2

    ;high_nibble*16
    clrf    result
    clrf    tens
    clrf    units
    clrf    temp 
    
    movf    high_nibble1, W
    swapf   WREG, W
    movwf   temp
    
    ;add low_nibble to temp
    movf    low_nibble1, W
    addwf   temp, F
    
    ;final result
    movf    temp,W
    movwf   result
    
    ;Get tens and units digits
    movf    result, W
    movwf   temp
    movlw   10                ; Load divisor (10) into WREG
    movwf   divisor           ; Store divisor
    
Divide_Loop:
    movf    temp, W       
    subwf   divisor, W    ; Subtract divisor from temp
    btfsc   STATUS, C     ; Check if the result is positive or zero
    goto    Subtract      ; If yes, perform subtraction
    goto    Division      ; If no, finish division

Subtract:
    movf    divisor, W    
    subwf   temp, F       ; Subtract divisor from temp
    incf    tens, F       ; Increment tens (quotient)
    goto    Divide_Loop   ; Repeat loop

Division:
    movf    temp, W       ; remainder in temp
    movwf   units         ; remainder -> units

    ;Display ASCII characters to LCD 
    
    ;Convert tens to ascii and display
    movf    tens, W           ; Load tens digit
    addlw   0x30              ; Convert to ASCII
    call    LCD_Write_Message      ; Display the tens digit

    ;Display the decimal point 
    movlw   '.'              
    call    LCD_Write_Message 
    
    ;Convert tens to ascii and display
    movf    units, W           ; Load units digit
    addlw   0x30              ; Convert to ASCII
    call    LCD_Write_Message      ; Display the tens digit
    
    return
    