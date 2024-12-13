#include <xc.inc>

global  
extrn	
extrn   

    EQU

psect	udata_acs   ; reserve data space in access ram
: ds 1
	
	
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data
    
initialise the heater
initialise the tremp reader
    

main loop
    store threshold temperature
    compare if temperature is greater than threshold
    if true then skin next line
    call subroutie: turn heater off
    
    
    call subroutine turn heater on
    repeat loop


subroutine turn heater off:
	turn heater off
	
	
initiliase heater
	
subroutine: turn heater on