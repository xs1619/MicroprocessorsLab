Convert_To_String:
    ; Assume counter holds the MSB of the temperature (integer part)
    
    ; Convert the integer part of the temperature to string
    movf    counter, W         ; Get the integer part (MSB of temperature)
    call    Digit_To_Ascii     ; Convert it to ASCII and store in myArray
    lfsr    2, myArray         ; Load FSR2 with address of myArray
    movf    POSTINC2, W        ; Move the ASCII value into W
    call    Digit_To_Ascii     ; Convert the next digit (LSB of temp_data) to ASCII and store

    ; Convert the decimal part (if needed)
    lfsr    0, temp_data       ; Load FSR0 with address of temp_data
    movf    POSTINC0, W        ; Get the LSB of the temperature (decimal part)
    call    Digit_To_Ascii     ; Convert decimal part to ASCII and store in myArray
    return

Digit_To_Ascii:
    ; Convert a single digit in W register to its ASCII representation
    addlw   '0'                ; Add ASCII value of '0' to convert number to ASCII
    movwf   POSTINC2           ; Store ASCII character in myArray and increment FSR2
    return
