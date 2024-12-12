; Subroutine to convert hexadecimal to decimal
; Input: Hexadecimal number
; Output: Decimal number

HexToDec:
    movlw   0x0A        ; Load 10 into WREG
    movwf   divisor     ; Store 10 in divisor
    clrf    quotient    ; Clear quotient
    clrf    remainder   ; Clear remainder

    ; Divide the hexadecimal number by 10
DivideLoop:
    movf    hexNum, W   ; hexadecimal to WREG
    subwf   divisor, W  ; Subtract divisor from WREG
    btfss   STATUS, C   ; Check if the result is negative
    goto    Done        ; If negative, exit loop
    incf    quotient, F ; Increment quotient
    movf    WREG, remainder ; Store remainder
    goto    DivideLoop  ; Repeat loop

Done:
    ; Combine quotient and remainder to get the decimal number
    movf    quotient, W ; Move quotient to WREG
    addwf   remainder, W ; Add remainder to WREG
    return

; Variables
hexNum      equ 0x20    ; Hexadecimal number
divisor     equ 0x21    ; Divisor (10)
quotient    equ 0x22    ; Quotient
remainder   equ 0x23    ; Remainder


