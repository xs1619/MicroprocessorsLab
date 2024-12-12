#include <xc.inc>

global  HexToDec, ;Loop, Result 
; Subroutine to convert hexadecimal to decimal

; Variables
hex_temp1  equ 0x02   ; From main routine
high_nibble1 equ 0x011
low_nibble1 equ 0x012
hex_temp2  equ 0x03
hex_hum1   equ 0x04
hex_hum2   equ 0x05  
   
HexToDec:
   
    ;extract high nibble 
    movlw   hex_temp1, W   ; Load temp(decimal) into WREG
    andlw   0xf0
    swapf   WREG, W
    movwf   high_nibble1
    
    ;extract low nibble 
    movlw   hex_temp1, W   ; Load temp(decimal) into WREG
    andlw   0x0f
    movwf   low_nibble1
    
    
    
    
    
    
    
    
    
    
    
    
    
    movwf   0x03
    movlw   hex_temp2, W   ; Load temp(decimal) into WREG
   
call Display_temp
    end
    
; Subroutine to display temperature
Display_temp:
    movwf  
    
    
Convert_to_ASCII:
    cpfsgt 
    addlw
    
    return     
    
    
    
    
    
    
    
Loop:
    movf   , W   ; hexadecimal to WREG
    subwf   , W  
    btfss   STATUS, C   ; Check if the result is negative
    goto    Result      ; If negative, exit loop
    incf    quotient, F ; Increment quotient
    movf    WREG, remainder ; Store remainder
    goto    Loop  ; Repeat loop

Result:
    
    return
    
    
    
