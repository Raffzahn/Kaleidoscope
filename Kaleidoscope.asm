;
; CROMEMCO DAZZLER KALEIDOSCOPE
; WRITTEN BY LI-CHEN WANG
;
; Reformated and commented Oct.2022 H.Franke

;-------------------------------------------

; Memory Structure
; 0000..007F Program
; 0080..00FF Stack (6 bytes used)
; 0200..09FF Video Buffer

TOP@ST   EQU   100H
VID@BF   EQU   200H


; Dazzler Video Registers
; Address Register at I/O Address 0Eh
; Bit 8     = On/Off
; Bit 6..1  = Address of Video Buffer

DAZ@A    EQU   0EH                      ; Dazzler Address Port Address
DAZ@ON   EQU   80H                      ; On/Off Bit

; Mode Register at I/O Address 0Fh
; Bit 8     = unused
; Bit 7     = Resolution
;             0 = Normal Resolution: 32x32x4 or 64x64x4
;             1 = High Resolution: 64x64x1 or 128x128x1
; Bit 6     = Memory Size
;             0 = 512 Bytes
;             1 = 2 KiB
; Bit 5     = Colour or B&W
;             0 = B&W
;             1 = Colour
; Bit 4..1  = IBGR  or Grey Level for set pixel in High Resolution (Bit 7 set)

;[Nowadays one would combine bit 7..5 into a video mode number like
; 0 (000) =  32 x  32 x 16 grey level per pixel
; 1 (001) =  32 x  32 x 16 colour per pixel
; 2 (010) =  64 x  64 x 16 grey level per pixel
; 3 (011) =  64 x  64 x 16 colour per pixel
; 4 (100) =  64 x  64 B&W with one predefined grey level and black
; 5 (101) =  64 x  64 colour with one predefined colour and black
; 6 (110) = 128 x 128 B&W with one predefined grey level and black
; 7 (111) = 128 x 128 colour with one predefined colour and black
;]

DAZ@M    EQU   0FH                      ; Dazzler Address Port Address
DAZ@HR   EQU   40h                      ; High Resolution (1)
DAZ@ML   EQU   20h                      ; Memory Size 512 Bytes (0) or 2 KiB (1)
DAZ@CO   EQU   10h                      ; Colour (1) or B&W (0)

; Synchronisation Register at I/O Address 0Eh
;[Added for completeness, not used here]
; Bit 8     = Even/Odd video line
; Bit 7     = End of Frame - Set during vertical retrace
; Bit 6..1  = Undefined
DAZ@S    EQU   0EH                      ; Dazzler Synchronization Port Address
DAZ@SL   EQU   40h                      ; Line Synchronisation
DAZ@SF   EQU   40h                      ; Frame Synchronisation

         ORG   0  ; Program Start at Reset

; Initialize Stack   
         LXI   SP,TOP@ST                ; Set Top of Stack to 100h

; Switch Dazzler output on and set address to 0200h
         MVI   A,DAZ@ON+(.HIGH.VID@BF/2) ; Enable Dazzler and set the video buffer start to 0200h (=081h)
         OUT   DAZ@A                    ; Send to address port

; Set Dazzler Video Mode to 64x64 @ 16 Individual Colours
         MVI   A,DAZ@ML+DAZ@CO          ; (=30h)
         OUT   DAZ@M                    ; Send to mode port

; Main Loop
HKS:                  
; Register usage during main loop:
;    H = Colour, cycles from 1Fh down to 01h
;        Every odd cycle uses black
;        Every even will produce a colour from F down to 1 (Black (0) will not be reached)
;    D = Mask (0..FFh) used to 'randomize' the next address
;    E = loop counter, counts down from 03FH to 0 
;    B = X coordinate * 8 (!)
;    C = Y coordinate * 8 (!)
; Note:
;    **No register is initialized prior to first iteration**
;    They may contain random values after RESET.
;    This will result in start at some location with some colour.

; Generate next 'random' pixel coordinate

; New Y = Last Y + ((Last X >> 2) AND MASK)
         MOV   A,B                      ; Last X >> 2
         RRC               
         RRC   
         ANA   D                        ; AND Mask
         ADD   C                        ; plus Last Y
         MOV   C,A                      ; -> New Y
; New X = Last X - ((New Y >> 2) AND MASK)
         RRC                            ; New Y >> 2
         RRC   
         ANA   D                        ; AND Mask
         MOV   L,A         
         MOV   A,B                      ; Last X
         SUB   L
         MOV   B,A                      ; -> New X

; Start drawing
         PUSH  B                        ; Save registers to free them for data during drawing
         PUSH  D  
         PUSH  H

         LXI   D,0                      ; Clear colour(s) (setting to black) in DE
         MOV   A,H                      ; Extract colour from H and prepare test for draw or clear
         ANI   01FH  
         RAR                            ; Low bit defines if black or other colour is used
         JC    DBLACK                   ; Bit was 0 -> draw pixel as black
  
; If it was not black, copy the 4-bit value into E and D
         MOV   E,A                      ; Colour to E for low pixel
         RLC                            ; Shift colour to high nibble for upper pixel
         RLC   
         RLC   
         RLC   
         MOV   D,A                      ;
DBLACK: 

; Draw a pixel mirrored 4 times
;
; In:
;   B/C = X/Y 0..31 in top 5 bits
;   D/E = Prepared colour value

; Works out quite easy, as the Dazzler memory in 2Ki mode
; is organized as 4 pages of 512 Bytes, each holding 1/4th
; of the display, 32x32 pixel in the selected mode. They
; are positioned as:
;
;                          0200h  I  0400h
;    Page 1  I  Page 2      ...   I   ... 
;            I             03FFh  I  05FFh
;    --------+--------     -------+-------
;            I             0600h  I  0800h
;    Page 3  I  Page 4      ...   I   ... 
;                          07FFh  I  09FFh
;
; Due to this organization in 4 quadrants it's quite easy
; to mirror a pixel's coordinates along both axis by simply
; negating each axis.
;
; Drawing is done clockwise starting in the lower right quadrant

; Draw Pixel in lower right quadrant
         MVI   H,08H                    ; H = Base Address Page 4, B/C=X/Y pixel within that page
         CALL  OUTPX                    ; Set pixel at X/Y

; Draw Pixel in lower left quadrant
         MOV   A,B                      ; Complement B to flip along X axis
         CMA
         MOV   B,A
         MVI   H,06H                    ; H = Base Address Page 3, B/C=X/Y pixel within that page
         CALL  OUTPX                    ; Set pixel at -X/Y

; Draw Pixel in upper left quadrant
         MOV   A,C                      ; Complement C to flip along Y axis
         CMA   
         MOV   C,A  
         MVI   H,02H                    ; H = Base Address Page 1, B/C=X/Y pixel within that page
         CALL  OUTPX                    ; Set pixel at -X/-Y

; Draw Pixel in upper right quadrant
         MOV   A,B                      ; Complement B (again) to flip (back) along X axis
         CMA   
         MOV   B,A  
         MVI   H,04H                    ; H = Base Address Page 2, B/C=X/Y pixel within that page
         CALL  OUTPX                    ; Set pixel at X/-Y

; Drawing complete, main loop continues
         POP   H                        ; Restore registers for main loop
         POP   D  
         POP   B

         DCR   E                        ; Have we done this 64 times?
         JNZ   HKS                      ; No -> back to the top of the loop

; Every 64th cycle, bump the colors, locations and mask to randomize drawing
         INR   B                        ; X = X + 1/8th
         INR   C                        ; Y = Y + 1/8th
         MVI   E,03FH                   ; Prepare another 64 rounds
         DCR   H                        ; But use the next colour (1Fh..1h)
                                        ; Lowest bit flips between black and colour 0..F
         JNZ   HKS                      ; Unless Black -> Do next iteration

         INR   D                        ; Increment mask for 'randomness'
         MVI   H,01FH                   ; Restart with colour 0Fh again
         JMP   HKS                      ; Start over

; Output a Pixel subroutine
; In:
;    H  High byte page base (2/4/6/8)
;    L  ---
;    B  X coordinate within page (Bit 8..5 -> A3..A0  bit 4 -> selects high/low pixel)
;    C  Y coordinate within page (Bit 8..4 -> A8..A4)   
;    D  Prepared Colour for Low Pixel  (in bit 4..1)
;    E  Prepared Colour for High Pixel (in bit 8..5)
; Out:
;    Pixel Set
;    A,H,L    destroyed
;    B,C,D,E  unchanged

; Step one:
;      Turn 5+5 bit x/y address into 9 bit address
;      plus high/low pixel marker

OUTPX:   MOV   A,C                      ; Upper 5 bits of pixel address
         ANI   0F8H                     ; Extract under Mask
         RAL                            ; Move high bit to Carry
         MOV   L,A                      ; Save to low byte of HL pointer

         MOV   A,H                      ; Get page base
         ACI   00H                      ; Add high bit to high byte of HL pointer
         MOV   H,A                      ; Save to high byte of HL pointer

         MOV   A,B                      ; Lower 5 bit of pixel address
         ANI   0F8H                     ; Extract under Mask
         RAR                            ; Move top 4 to lower nibble, lowest to carry
         RAR   
         RAR   
         RAR   
         PUSH  PSW                      ; Preserve Carry Flag holding the pixel 'address' 
         ADD   L                        ; Add lower nibble to low byte of HL pointer
         MOV   L,A                      ; Save to low bye of HL pointer
         POP   PSW                      ; Restore Carry flag containing the lowest pixel address
                                        ; CY=0 Low Pixel; CY=1 High Pixel

; Step two:
;      Set high or low Pixel, according to the carry bit, to the drawing colour 

         MOV   A,M                      ; Read existing pixel pair
         JC    OUTHPX                   ; CY set -> go do high pixel
                                        ; CY cleared -> do low pixel
; Output Low Pixel
         ANI   0F0H                     ; Mask out (clear) old low pixel
         ADD   E                        ; Insert new low pixel
         MOV   M,A                      ; Store in video buffer
         RET

; Output High Pixel
OUTHPX:  ANI   0FH                      ; Mask out (clear) old high pixel  
         ADD   D                        ; Insert new high pixel
         MOV   M,A                      ; Store in video buffer
         RET   

         END
