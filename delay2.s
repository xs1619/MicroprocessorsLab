	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100	    

setup:
        bcf CFGS              ; Point to Flash program memory
        bsf EEPGD             ; Access program memory
        clrf PORTC            ; Clear PORTC 
        movlw 0x00
        movwf TRISC           ; Set PORTC as output
        goto start            ; Jump to main program

myTable:
        db 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 ; LED patterns
        db 0xAA, 0x55         ; Additional patterns for flashing
    
        myArray EQU 0x400         ; Address in RAM for data if needed (optional)
        counter EQU 0x08          ; Set counter to the number of patterns in myTable
        ;align	2		; ensure alignment of subsequent instructions
 
start:

        lfsr 0, myArray       ; Load FSR0 with RAM address if storing data (optional)
        movlw low highword(myTable)
        movwf TBLPTRU, A         ; Load upper bits of myTable address
        movlw high(myTable)
        movwf TBLPTRH, A         ; Load high byte of myTable address
        movlw low(myTable)
        movwf TBLPTRL, A         ; Load low byte of myTable address
        movlw counter         ; Load counter with the number of patterns
        movwf counter, A

loop:

        tblrd*+               ; Read byte from program memory into TABLAT
        movff TABLAT, PORTC   ; Output byte to PORTC (display pattern on LEDs)
	
    ; Delay subroutine
    
        decfsz counter, A     ; Decrement counter; skip if zero
        bra loop              ; Repeat until all patterns are displayed
        goto 0   ; End program (loop here indefinitely)

    
        end main


