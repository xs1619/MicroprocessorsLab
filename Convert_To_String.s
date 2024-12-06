#include <xc.inc>



psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data
    
psect udata_acs
digit_temp: ds 1         ; Temporary storage for division remainder
quotient:   ds 1         ; Temporary storage for quotient

psect	convert_string_code,class=CODE
    
Convert_To_String:
    ; Input: W holds the number to convert
    ; Output: ASCII digits are stored in myArray
    ; Requires: FSR2 must point to myArray before calling this subroutine

    ; Initialize FSR2 to point to myArray
    lfsr    2, myArray

    ; Step 1: Divide number by 100 to get the hundreds digit
    movlw   100
    call    Divide            ; Perform division
    movf    quotient, W       ; Get quotient (hundreds digit)
    addlw   '0'               ; Convert to ASCII
    movwf   POSTINC2          ; Store ASCII digit in myArray

    ; Step 2: Divide remainder by 10 to get the tens digit
    movf    digit_temp, W     ; Move remainder to W
    movlw   10
    call    Divide            ; Perform division
    movf    quotient, W       ; Get quotient (tens digit)
    addlw   '0'               ; Convert to ASCII
    movwf   POSTINC2          ; Store ASCII digit in myArray

    ; Step 3: Remainder is the units digit
    movf    digit_temp, W     ; Get the units digit
    addlw   '0'               ; Convert to ASCII
    movwf   POSTINC2          ; Store ASCII digit in myArray

    ; Step 4: Null-terminate the string
    clrf    WREG
    movwf   POSTINC2          ; Null-terminate the string

    return

Divide:
    ; Perform division of W by movlw value
    ; Input: W holds dividend, movlw holds divisor
    ; Output: quotient -> stored in `quotient`
    ;         remainder -> stored in `digit_temp`

    clrf    quotient          ; Clear quotient
    clrf    digit_temp        ; Clear remainder

Divide_Loop:
    subwf   digit_temp, W     ; Subtract divisor from dividend
    btfss   STATUS, 0         ; Check if result is positive
    goto    Divide_Done
    movwf   digit_temp
    incf    quotient, F
    goto    Divide_Loop

Divide_Done:
    
    return
