#include <xc.inc>

global  HexToDec, Divide_Loop, Subtract, Division
extrn	LCD_Send_Byte_D 
extrn	data_buffer
global	remainder, quotient, temp, divisor, result
; Subroutine to convert hexadecimal to decimal

psect udata_acs
 
; Variables
hex_temp1    EQU data_buffer   ; From main routine
high_nibble1: ds 1
low_nibble1: ds 1
hex_temp2    EQU data_buffer + 1
high_nibble2: ds 1
low_nibble2: ds 1
hex_hum1     EQU data_buffer + 2
hex_hum2     EQU data_buffer + 3                                            
   
temp: ds 1
result: ds 1
quotient: ds 1
remainder: ds 1
divisor: ds 1
   
psect	conversion_code,class=CODE

HexToDec:
    ;temp
    ;extract high nibble 
    movf    hex_temp1, W, A      ; Load temp(integer) into WREG
    andlw   0xf0
    swapf   WREG, F, A
    movwf   high_nibble1, A
    
    ;extract low nibble 
    movf    hex_temp1, W, A      ; Load temp into WREG
    andlw   0x0f
    movwf   low_nibble1, A
    
     ;extract high nibble 
    movf    hex_temp2, W, A      ; Load temp(decimal) into WREG
    andlw   0xf0
    swapf   WREG, F, A
    movwf   high_nibble2, A
    
    ;extract low nibble 
    movf    hex_temp2, W, A       ; Load temp(decimal) into WREG
    andlw   0x0f
    movwf   low_nibble2, A

    ;high_nibble*16
    clrf    result, A
    clrf    temp, A 
    
    movf    high_nibble1, W, A
    swapf   WREG, F, A
    movwf   temp, A
    
    ;add low_nibble to temp
    movf    low_nibble1, W, A
    addwf   temp, F, A
    
    ;final result
    movf    temp, W, A
    movwf   result, A
    
    ;Get tens and units digits
    movf    result, W, A
    movwf   temp, A
    movlw   10                ; Load divisor (10) into WREG
    movwf   divisor, A           ; Store divisor
  
    clrf    quotient, A
    clrf    remainder, A
    call    Divide_Loop
    addlw   0x30              ; Convert to ASCII
    call    LCD_Send_Byte_D      ; Display the tens digit
    
    ;Display the decimal point 
    movlw   '.'              
    call    LCD_Send_Byte_D
    
     ;Convert tens to ascii and display
    movf    remainder, W, A           ; Load units digit
    addlw   0x30              ; Convert to ASCII
    call    LCD_Send_Byte_D      ; Display the tens digit
    return
    
Divide_Loop:
    movf    divisor, W, A       
    subwf   temp, W, A    ; Subtract divisor from temp
    btfsc   CARRY	; Check if the result is positive or zero
    goto    Subtract      ; If yes, perform subtraction
    goto    Division      ; If no, finish division??????

Subtract:
    movf    divisor, W, A    
    subwf   temp, F, A       ; Subtract divisor from temp
    incf    quotient, F, A       ; Increment tens (quotient)
    goto    Divide_Loop   ; Repeat loop

Division:
    movf    temp, W, A     
    movwf   remainder, A        
    return
    
end