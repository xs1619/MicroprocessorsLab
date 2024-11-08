	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100	    

setup:
        bcf CFGS              ; Point to Flash program memory
        bsf EEPGD             ; Access program memory
        clrf PORTH            ; Clear PORTH 
        movlw 0x00
        movwf TRISH           ; Set PORTH as output
        goto start            ; Jump to main program

myTable:
        db 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 ; LED patterns
        db 0xAA, 0x55         ; Additional patterns for flashing
    
        myArray EQU 0x400         ; ()
        counter EQU 0x08          ; Set counter to the number of patterns in myTable
        delay_count EQU 0x10
        ;align	2		; ensure alignment of subsequent instructions
 
start:

        lfsr 0, myArray       ; ()
        movlw low highword(myTable)
        movwf TBLPTRU, A         ; Load upper bits of myTable address
        movlw high(myTable)
        movwf TBLPTRH, A         ; Load high byte of myTable address
        movlw low(myTable)
        movwf TBLPTRL, A         ; Load low byte of myTable address
        movlw counter         ; Load counter with the number of patterns
        movwf counter, A

loop:

        tblrd*+               
        movff TABLAT, PORTH   ; Output to PORTH 
	call delay
        decfsz counter, A     
        bra loop              
        goto 0   
	
;delay 10 seconds
delay:
        movlw 0xff
	movwf delay_count
	
delay_loop:
        decfsz delay_count, A
	bra delay_loop
	
	return 
        end main


