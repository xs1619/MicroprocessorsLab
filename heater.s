#include <xc.inc>

global  heater_setup, heater_on, heater_off
extrn	
extrn   

    EQU

psect	udata_acs   ; reserve data space in access ram
: ds 1
	
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data    
psect	heater_code,class=CODE
    

subroutine heater_setup
    
    
sub routine heater on
    
    
sub routine heater off
    
   