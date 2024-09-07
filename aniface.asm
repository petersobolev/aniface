
; 820 bytes intro "AniFace" by Frog //ROi
; for Chaos Constructions'2024
;
; https://enlight.ru/roi
; frog@enlight.ru
;

                include "vectrex.i"

counter         equ     $C880
intensity_corr  equ     $C882
eye_phase       equ     $C884
pixelsRAM       equ	  $C888    ;C884


                org     0

                db      "g GCE 2015", $80 	; 'g' is copyright sign
                dw      $F600            	; music from the rom (no music)
                db      $FC, $30, 33, -$23	; height, width, rel y, rel x
	            db      "ANIFACE", $80	; app title, ending with $80
                db      0                 	; end of header


                clr    counter
                clr    eye_phase


                lda    #-100
                sta    intensity_corr

; copy pixels structure to RAM
                ldu    #pixels
                ldx    #pixelsRAM
;                lda    #(5)
                lda    #(pixels_end - pixels)
                jsr    Move_Mem_a            ; A - byte count, U - source, X - destination


loop:
                jsr     Wait_Recal        	; recalibrate CRT, reset beam to 0,0

                lda     #$ff              	; scale (max possible)
                sta     <VIA_t1_cnt_lo

                jsr     Intensity_5F

; eye
                ldd     #(13*256+(-12)) 	; Y,X
                jsr     Moveto_d

                ldd     #(7*256+(-12)) 	; Y,X
                jsr     Draw_Line_d







                lda    eye_phase

            	   ldx    #eye_phases
            	   lda    a,x	; get result phase
            	   bpl    skip_reset_phase

                clr    eye_phase
            	   lda    eye_phases	; get result phase (first value)
skip_reset_phase:	

                ldb    counter
                bitb   #$07            ; change phase only each nth frame
                bne    skipinc
                inc    eye_phase
                
               
skipinc:

                ldb    #18





;                ldd     #(1*256+(18)) 	; Y,X  change y
                jsr     Draw_Line_d

; upper eyebrow
                ldd     #(15*256+(-15)) 	; Y,X
                jsr     Moveto_d

                ldd     #(-4*256+(17)) 	; Y,X

                lda    eye_phase
            	   ldx    #eyebrow_phases
            	   lda    a,x	; get result phase


                jsr     Draw_Line_d


; text

                ldu     #alltext
                jsr     Print_List_hw


                jsr     Reset0Ref               ; recalibrate crt (x,y = 0)

; draw dots with "motion blur"


        
                ldy    #(0*256+(0))    ; Y,X
next_dot:
                tfr    y,d

                exg	a,b

                lsla
                lsla

                adda    intensity_corr
               
                jsr     Intensity_a            ; Sets the intensity of the
                                                ; vector beam to $5f

                lda     #5                      ; load A with number of dots - 1
                sta     Vec_Misc_Count          ; set it as counter for dots
                ldx     #pixelsRAM               ; load the address of dots list
                jsr     Dot_List

                tfr     y,d    

                negb
                jsr     Moveto_d

                leay    3,Y

                cmpy    #26
                blo     next_dot

                jsr     Intensity_7F


                jsr     Reset0Ref               ; recalibrate crt (x,y = 0)
                lda     #$CE                    ; /Blank low, /ZERO high
                sta     <VIA_cntl               ; enable beam, disable zeroing

                ldd     #(116*256+(-22))         ; Y,X
                jsr     Moveto_d


; start drawing face

                ldb     #$ff
                stb     <VIA_shift_reg     	; pattern


                ldd     #$1881
                stb     <VIA_port_b        	; disable MUX, disable ~RAMP
                sta     <VIA_aux_cntl      	; AUX: shift mode 4. PB7 not timer controlled. PB7 is ~RAMP

                lda     #-50              	; destination Y -86
                sta     <VIA_port_a        	; destination Y to DAC

                decb                      	; b now $80
                stb     <VIA_port_b        	; enable MUX

                clrb
                inc     <VIA_port_b        	; MUX off, only X on DAC now
                stb     <VIA_port_a        	; X to DAC

                lda     #50
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

                incb
                stb     <VIA_port_b        	; MUX disable, ~RAMP enable. Start integration

                nop
                nop

                lda     #37
                sta     <VIA_port_a        	; put X to DAC 

; 10 nops
                ldb    #2            ; 2 cycles
d7a:            decb                   ; 2 cycles
                bpl     d7a             ; 3 cycles

                lda     #30
                sta     <VIA_port_a        	; put X to DAC 

; 10 nops
                ldb    #2            ; 2 cycles
d6a:            decb                   ; 2 cycles
                bpl     d6a             ; 3 cycles

                lda     #27
                sta     <VIA_port_a        	; put X to DAC 

; 10 nops
                ldb    #2            ; 2 cycles
d5a:            decb                   ; 2 cycles
                bpl     d5a             ; 3 cycles

                lda     #25
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop
                nop
                nop
                nop

                lda     #15
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop
                nop
                nop
                nop

                lda     #10
                sta     <VIA_port_a        	; put X to DAC 

; 9 nops
                ldb    #2            ; 2 cycles
d4a:            decb                   ; 2 cycles
                bpl     d4a             ; 3 cycles


                lda     #5
                sta     <VIA_port_a        	; put X to DAC 


                nop

                lda     #3
                sta     <VIA_port_a        	; put X to DAC 

                nop

                lda     #-5
                sta     <VIA_port_a        	; put X to DAC 

                nop

                lda     #-13
                sta     <VIA_port_a        	; put X to DAC 

                nop

                lda     #-18
                sta     <VIA_port_a        	; put X to DAC 

; 14 nops
                ldb    #3            ; 2 cycles
d3a:            decb                   ; 2 cycles
                bpl     d3a             ; 3 cycles


                lda     #0        ; nose top
                sta     <VIA_port_a        	; put X to DAC 

                nop
           
                lda     #10
                sta     <VIA_port_a        	; put X to DAC 
            
                nop

                lda     #20
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop

                lda     #30
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop

                lda     #40
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop

                lda     #45
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop

                lda     #55
                sta     <VIA_port_a        	; put X to DAC 

; 15 nops
                ldb    #3            ; 2 cycles
d2a:            decb                   ; 2 cycles
                bpl     d2a             ; 3 cycles


                lda     #20
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop
                nop

                lda     #-20
                sta     <VIA_port_a        	; put X to DAC 





                lda     #-60
                sta     <VIA_port_a        	; put X to DAC 


                lda     #-80
                sta     <VIA_port_a        	; put X to DAC 

                lda     #-127
                sta     <VIA_port_a        	; put X to DAC 

                lda     #-80
                sta     <VIA_port_a        	; put X to DAC 

                lda     #-60                                ; nose bottom
                sta     <VIA_port_a        	; put X to DAC 


                lda     #10                                            
                sta     <VIA_port_a        	; put X to DAC 

                lda     #50                                            
                sta     <VIA_port_a        	; put X to DAC 

                lda     #40                                            
                sta     <VIA_port_a        	; put X to DAC 

; 6 nops                
                ldb    #1            ; 2 cycles
d1a:            decb                   ; 2 cycles
                bpl     d1a             ; 3 cycles


                lda     #0                                            
                sta     <VIA_port_a        	; put X to DAC 


                lda     #-100                                            
                sta     <VIA_port_a        	; put X to DAC 

                lda     #-80                                            
                sta     <VIA_port_a        	; put X to DAC 

                nop


; line between lips (to the left)




                ldd     #$1881
                stb     <VIA_port_b        	; disable MUX, disable ~RAMP
                sta     <VIA_aux_cntl      	; AUX: shift mode 4. PB7 not timer controlled. PB7 is ~RAMP

                lda     #-13              	; destination Y 
                sta     <VIA_port_a        	; destination Y to DAC

                decb                      	; b now $80
                stb     <VIA_port_b        	; enable MUX

                clrb
                inc     <VIA_port_b        	; MUX off, only X on DAC now
                stb     <VIA_port_a        	; X to DAC

             
                incb
                stb     <VIA_port_b        	; MUX disable, ~RAMP enable. Start integration

                lda     #-127
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)
                nop

    
; line between lips (to the right)




                ldd     #$1881
                stb     <VIA_port_b        	; disable MUX, disable ~RAMP
                sta     <VIA_aux_cntl      	; AUX: shift mode 4. PB7 not timer controlled. PB7 is ~RAMP

                lda     #-1              	; destination Y 


                lda    eye_phase
            	   ldx    #lips_phases
            	   lda    a,x	; get result phase
                lsla
                lsla


    
                sta     <VIA_port_a        	; destination Y to DAC

                decb                      	; b now $80
                stb     <VIA_port_b        	; enable MUX

                clrb
                inc     <VIA_port_b        	; MUX off, only X on DAC now
                stb     <VIA_port_a        	; X to DAC

             
                incb
                stb     <VIA_port_b        	; MUX disable, ~RAMP enable. Start integration

;            lda counter
                lda     #127
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)
                nop



; lower part of face

                 ;           clr     <VIA_shift_reg  	; Blank beam in VIA shift register
       


                ldd     #$1881
                stb     <VIA_port_b        	; disable MUX, disable ~RAMP
                sta     <VIA_aux_cntl      	; AUX: shift mode 4. PB7 not timer controlled. PB7 is ~RAMP

                lda     #-30              	; destination Y 
                sta     <VIA_port_a        	; destination Y to DAC

                decb                      	; b now $80
                stb     <VIA_port_b        	; enable MUX

                clrb
                inc     <VIA_port_b        	; MUX off, only X on DAC now
                stb     <VIA_port_a        	; X to DAC

                lda     #100
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

                incb
                stb     <VIA_port_b        	; MUX disable, ~RAMP enable. Start integration

                lda     #20
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)



; 16 nops
                ldb    #3            ; 2 cycles
d1:             decb                   ; 2 cycles
                bpl     d1             ; 3 cycles




                lda     #-20
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

                nop
                nop
                nop
                nop

                lda     #-43
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)



; 9 nops
                ldb    #2            ; 2 cycles
d2:             decb                   ; 2 cycles
                bpl     d2             ; 3 cycles


                lda     #20
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

; 9 nops
                ldb    #2            ; 2 cycles
d3:             decb                   ; 2 cycles
                bpl     d3             ; 3 cycles


                lda     #5
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

; 9 nops
                ldb    #2            ; 2 cycles
d4:             decb                   ; 2 cycles
                bpl     d4             ; 3 cycles

                lda     #0
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

                nop
                nop
                nop

                lda     #-10
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

; 9 nops
                ldb    #2            ; 2 cycles
d5:             decb                   ; 2 cycles
                bpl     d5             ; 3 cycles

                lda     #-30
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

; 9 nops
                ldb    #2            ; 2 cycles
d6:             decb                   ; 2 cycles
                bpl     d6             ; 3 cycles

                lda     #-85
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

; 7 nops
                ldb    #1            ; 2 cycles
d7:             decb                   ; 2 cycles
                bpl     d7             ; 3 cycles



                ldb     #$81              	; ramp off, MUX off
                stb     <VIA_port_b

                lda     #$98
                sta     <VIA_aux_cntl      	; restore usual AUX setting (enable PB7 timer, SHIFT mode 4)

                clr     <VIA_shift_reg  	; Blank beam in VIA shift register





                jsr     Reset0Ref               ; recalibrate crt (x,y = 0)
                lda     #$CE                    ; /Blank low, /ZERO high
                sta     <VIA_cntl               ; enable beam, disable zeroing

                ldd     #(40*256+(-29))         ; Y,X   39

                lda    eye_phase
            	   ldx    #pupil_phases
            	   lda    a,x	; get result phase


                jsr     Moveto_d



; pupil

                ldb     #$ff
                stb     <VIA_shift_reg     	; pattern


                ldd     #$1881
                stb     <VIA_port_b        	; disable MUX, disable ~RAMP
                sta     <VIA_aux_cntl      	; AUX: shift mode 4. PB7 not timer controlled. PB7 is ~RAMP

;                lda     #-35              	; destination Y -50

                lda    eye_phase
            	   ldx    #pupil_phases2
            	   lda    a,x	; get result phase

                sta     <VIA_port_a        	; destination Y to DAC

                decb                      	; b now $80
                stb     <VIA_port_b        	; enable MUX

                clrb
                inc     <VIA_port_b        	; MUX off, only X on DAC now
                stb     <VIA_port_a        	; X to DAC

                lda     #0
                sta     <VIA_port_a        	; put X to DAC  (it's before RAMP enable to avoid straight line chunk)

                incb
                stb     <VIA_port_b        	; MUX disable, ~RAMP enable. Start integration

                nop
                nop

                lda     #-23
                sta     <VIA_port_a        	; put X to DAC 

                nop
                nop

                lda     #-48
                sta     <VIA_port_a        	; put X to DAC 

                nop



                ldb     #$81              	; ramp off, MUX off
                stb     <VIA_port_b

                lda     #$98
                sta     <VIA_aux_cntl      	; restore usual AUX setting (enable PB7 timer, SHIFT mode 4)

                clr     <VIA_shift_reg  	; Blank beam in VIA shift register


                inc     counter

                ldd    pixelsRAM+1

                deca
                cmpa    #20
                bne    S1

                lda    #-100

                lda    #127
S1:
                std    pixelsRAM+1

                dec    pixelsRAM+1
                dec    pixelsRAM+1+2
                dec    pixelsRAM+1+2+2
                dec    pixelsRAM+1+2+2
                dec    pixelsRAM+1+2+2+2
                dec    pixelsRAM+1+2+2+2
                dec    pixelsRAM+1+2+2+2+2

                inc    intensity_corr    ; fade in dots gradually

                bra     loop

; Text lines
; height, width, rel y, rel x, string, eol ($80)

alltext:
                db      $fc,$20,5,-115,' ',$80
                db      $fc,$20,46,-122,'ANIFACE',$80
                db      $fc,$20,30,-122,'1 KB',$80
                db      $fc,$20,14,-122,'BY FROG',$80
                db      $fc,$20,-4,-122,'FOR CC',$27,'2024',$80
                db      0

pixels:
                db       100,127                 ; several dots, relative
                db      -20, 11                 ; position, Y, X
                db       -30, 5
                db       -50, 20
                db       -50, -20
                db       -25, -8
pixels_end:

eye_phases:              
                db      1,2,3,4,3,2,1,-1

lips_phases:              
                db      -1,-2,-4,-7,-4,-2,-1,-1
;                db      -1,-2,-3,-5,-3,-2,-1,-1

eyebrow_phases:
                db      -4,-3,-2,-1,-2,-3,-4,-4,-4

pupil_phases:
               db      36,37,38,38,38,36,36,36,36
;               db      36,37,38,38,38,38,38,37,36
pupil_phases2:
                db      -40,-40,-40,-39,-40,-40,-40,-40,-40
;                db      -36,-36,-36,-35,-36,-36,-36,-36,-36


