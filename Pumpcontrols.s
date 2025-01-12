#include <xc.inc>
global pump_on, pump_off

 psect udata
 sdelaycount: ds 1
 psect	pump_code,class=CODE

 pump_on:   
	;bcf	    TRISC, 0, A	    ;supposed to pull the line high
	;bcf	    LATC, 1, A
	movlw	    00000011B
	bsf	    LATC, 2, A
	return
    
    
 pump_off:
	;bcf	    TRISC, 0, A	    ;supposed to pull the line low
	;bcf	    LATC, 0, A
	bcf	    LATC, 2, A	    ;clears bit 0 on portb resulting in a low
	return
	
