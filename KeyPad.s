#include <xc.inc>
    
global  KeyPad_Setup, KeyPad_Read, new_data, KeyPad_Decode
extrn   myTable, myTable_l,LCD_Send_Byte_D


psect	udata_acs   ; reserve data space in access ram

KeyPad_counter: ds    1	    ; reserve 1 byte for variable UART_counter
new_data: ds	1
   

    
    

psect	KeyPad_code,class=CODE
KeyPad_Setup:
    banksel PADCFG1
    bsf     REPU
    banksel 0
    clrf    LATE
    clrf    TRISD
    return

KeyPad_Read:
    
    movlw   0x0F
    movwf   TRISE
    call    Delay
    movf    PORTE, w
    movwf   new_data, A
    
    movlw   0xF0
    movwf   TRISE
    call    Delay
    movf    PORTE, w
    addwf   new_data, A
    movff   new_data, PORTD
    return 
    
KeyPad_Decode:
    movlw   11101110B
    cpfseq  new_data, A
    bra	    check_2
    movlw   '1'
    call LCD_Send_Byte_D
    return
    
;    addwf myTable
;    incf myTable_l,F
    
check_2:
    movlw   11101101B
    cpfseq  new_data, A
    bra	    check_3
    movlw   '2'
    call LCD_Send_Byte_D
    return
check_3:
    movlw   11101011B
    cpfseq  new_data, A
    bra     check_F
    movlw   '3'
    call LCD_Send_Byte_D
    return
check_F:
    movlw   11100111B
    cpfseq  new_data, A
    bra     check_4
    movlw   'F'
    call LCD_Send_Byte_D
    return
check_4:
    movlw   11011110B
    cpfseq  new_data, A 
    bra     check_5
    movlw   '4'
    call LCD_Send_Byte_D
    return
check_5:
    movlw   11011101B
    cpfseq  new_data, A
    bra     check_6
    movlw   '5'
    call LCD_Send_Byte_D
    return
check_6:
    movlw   11011011B
    cpfseq  new_data, A
    bra     check_E
    movlw   '6'
    call LCD_Send_Byte_D
    return
check_E:
    movlw   11010111B
    cpfseq  new_data, A
    bra     check_7
    movlw   'E'
    call LCD_Send_Byte_D
    return
check_7:
    movlw   10111110B
    cpfseq  new_data, A
    bra     check_8
    movlw   '7'
    call LCD_Send_Byte_D
    return
check_8:
    movlw   10111101B
    cpfseq  new_data, A
    bra     check_9
    movlw   '8'
    call LCD_Send_Byte_D
    return
check_9:
    movlw   10111011B
    cpfseq  new_data, A
    bra     check_D
    movlw   '9'
    call LCD_Send_Byte_D
    return
check_D:
    movlw   10110111B
    cpfseq  new_data, A
    bra     check_A
    movlw   'D'
    call LCD_Send_Byte_D
    return
check_A:
    movlw   01111110B
    cpfseq  new_data, A
    bra     check_0
    movlw   'A'
    call LCD_Send_Byte_D
    return
check_0:
    movlw   01111101B
    cpfseq  new_data, A
    bra     check_B
    movlw   '0'
    call LCD_Send_Byte_D
    return
check_B:
    movlw   01111011B
    cpfseq  new_data, A
    bra     check_C
    movlw   'B'
    call LCD_Send_Byte_D
    return
check_C:
    movlw   01110111B
    cpfseq  new_data, A
    bra     ferror
    movlw   'C'
    call LCD_Send_Byte_D
    return
ferror:
    movlw   'X'
    call LCD_Send_Byte_D
    return

    
    

    
Delay:
    movlw	100	    ; delay 40us
    movwf   KeyPad_counter, A
KeyPad_Loop:
    decfsz  KeyPad_counter, A
    bra	    KeyPad_Loop
    return

KeyPad_Transmit_Byte:	    ; Transmits byte stored in W
    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    KeyPad_Transmit_Byte
    movwf   TXREG1, A
    return

