#include <xc.inc>
    
global fan_on, fan_off


 psect	fan_code,class=CODE
 
 fan_on:   
	bsf	    LATC, 0, A	    ;sets bit on LatC0 setting output to 1
	return
    
    
 fan_off:
	bcf	    LATC, 0, A	    ;clears bit on LatC0 setting output to 0
	return
	
    end



