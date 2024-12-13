#include <xc.inc>

global  HexToDec, HexToDec2, Divide_Loop, Subtract, Division
extrn	LCD_Send_Byte_D 
extrn	data_buffer
global	remainder, quotient, temp, temph, divisor, result
; Subroutine to convert hexadecimal to decimal

psect udata_acs
 
; Variables
hex_hum1    EQU data_buffer   ; From main routine
high_nibble1: ds 1
low_nibble1: ds 1
hex_hum2    EQU data_buffer + 1
high_nibble2: ds 1
low_nibble2: ds 1
hex_temp1     EQU data_buffer + 2
hex_temp2     EQU data_buffer + 3                                            
   
temp: ds 1
temph: ds 1
result: ds 1
quotient: ds 1
remainder: ds 1
divisor: ds 1
   
psect conversion_code,class=CODE

HexToDec:
    clrf    result, A
    
    ;movff   hex_temp1, temph
    ;movff   hex_temp2, temp
    
    ;final result
    movf    temp, W, A
    movwf   result, A
    
    ;Get tens and units digits
    movf    result, W, A
    movwf   temp, A
    movlw   100                ; Load divisor (100) into WREG
    movwf   divisor, A           ; Store divisor
  
    clrf    quotient, A
    clrf    remainder, A
    call    Divide_Loop
    
     ;Convert tens to ascii and display
    movf    quotient, W, A           ; Load units digit
    addlw   0x30              ; Convert to ASCII
    call    LCD_Send_Byte_D      ; Display the units digit
    
    movf    remainder, W, A
    movwf   temp, A
    movlw   10                    ; Load divisor (100) into WREG
    movwf   divisor, A           ; Store divisor
    
    clrf    quotient, A
    clrf    remainder, A
    call    Divide_Loop
    movf    quotient, W, A
    addlw   0x30              ; Convert to ASCII
    call    LCD_Send_Byte_D      ; Display the tens digit
    
    ;Display the decimal point 
    movlw   '.'              
    call    LCD_Send_Byte_D
    
    ;Convert tens to ascii and display
    movf    remainder, W, A           ; Load units digit
    addlw   0x30              ; Convert to ASCII
    call    LCD_Send_Byte_D      ; Display the units digit
    
    return

HexToDec2:
    ;Display the decimal point 
    movlw   '.'              
    call    LCD_Send_Byte_D
    
    movlw   '%'              
    call    LCD_Send_Byte_D
    
    return
    
Divide_Loop:
    movf    divisor, W, A       
    subwf   temp, W, A    ; Subtract divisor from temp
    btfsc   CARRY	  ; Negative result
    goto    Subtract
contH:
    decf    temph, F, A
    btfsc   CARRY	  ; Check if the result is positive or zero
    goto    Subtract      ; If yes, perform subtraction
    goto    Division      ; If no, finish division

Subtract:
    movf    divisor, W, A    
    subwf   temp, F, A       ; Subtract divisor from temp
    incf    quotient, F, A       ; Increment tens (quotient)
    goto    Divide_Loop   ; Repeat loop

Division:
    incf    temph, F, A
    movf    temp, W, A     
    movwf   remainder, A        
    return
    
end