'
' Project: pico9918
'
' PICO9918 Configurator
'
' Copyright (c) 2024 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/pico9918
'

' pattern indices
CONST PATT_IDX_SELECTED_L = 20
CONST PATT_IDX_SELECTED_R = 21
CONST PATT_IDX_BORDER_H   = 22
CONST PATT_IDX_BORDER_V   = 23
CONST PATT_IDX_BORDER_TL  = 24
CONST PATT_IDX_BORDER_TR  = 25
CONST PATT_IDX_BORDER_BL  = 26
CONST PATT_IDX_BORDER_BR  = 27
CONST PATT_IDX_SWATCH     = PATT_IDX_SELECTED_L + 128
CONST PATT_IDX_SLIDER     = PATT_IDX_BORDER_H + 128
CONST PATT_IDX_BORDER_HD  = PATT_IDX_BORDER_TL + 128
CONST PATT_IDX_BORDER_HU  = PATT_IDX_BORDER_TR + 128
CONST PATT_IDX_BORDER_VL  = PATT_IDX_BORDER_BL + 128
CONST PATT_IDX_BORDER_VR  = PATT_IDX_BORDER_BR + 128
CONST PATT_IDX_BOX_TL     = 28
CONST PATT_IDX_BOX_TR     = 29
CONST PATT_IDX_BOX_BL     = 30
CONST PATT_IDX_BOX_BR     = 31

DIM pattBuf(8)

fillBuff: PROCEDURE
    FOR T = 0 TO 7
        pattBuf(T) = C
    NEXT T
    END

createPattern: PROCEDURE
    GOSUB fillBuff
    DEFINE CHAR I, 1, VARPTR pattBuf(0)
    END



#fontTable:
    DATA $0100, $0900, $1100, $0500, $0D00, $1500

blockColors:
    DATA BYTE 1, $c0    ' 0
    DATA BYTE 1, $a0    ' 1
    DATA BYTE 1, $80    ' 2
    DATA BYTE 17, $f0   ' 3 - 19
    DATA BYTE 8, $40    ' 20 - 27
    DATA BYTE 4, $f0    ' 28 - 31
    DATA BYTE 96, $e0   ' 32 - 127
    DATA BYTE 20, $f0   ' 128 - 147
    DATA BYTE 1, $01    ' 148
    DATA BYTE 11, $40   ' 149 - 160
    DATA BYTE 91, $f4   ' 160 - 251
    DATA BYTE 5, $f0    ' 251 - 255

patterns:
    DATA BYTE $01, $80, $00, $00

' -----------------------------------------------------------------------------
' set up the various tile patters and colors
' -----------------------------------------------------------------------------
setupTiles: PROCEDURE
    FOR I = 0 TO 5
        DEFINE VRAM PLETTER #fontTable(I), $300, font
    NEXT I

    I = 0
    FOR R = 0 TO 23 STEP 2
        G = blockColors(R)
        C = blockColors(R + 1)
        GOSUB fillBuff
        WHILE G
            DEFINE COLOR I, 1, VARPTR pattBuf(0)
            G = G - 1 : I = I + 1
        WEND
    NEXT R

    FOR I = 0 TO 2
        DEFINE CHAR I, 1, block
        DEFINE VRAM #VDP_COLOR_TAB1 + (I * 8), 8, VARPTR pattBuf(0) 
    NEXT I

    FOR I = 3 TO 6
        C = patterns(I - 3)
        GOSUB createPattern
    NEXT I
    VPOKE #VDP_PATT_TAB2 + 5 * 8 + 7, $ff
    VPOKE #VDP_PATT_TAB2 + 6 * 8, $ff

    DEFINE VRAM PLETTER #VDP_PATT_TAB1 + 1 * 8, 19 * 8, logo
    DEFINE VRAM PLETTER #VDP_PATT_TAB1 + 129 * 8, 19 * 8, logo2

#if SPRITE_TEST
    DEFINE VRAM PLETTER #VDP_SPRITE_PATT, $e0, logoSprites
#endif

    DEFINE CHAR PATT_IDX_BORDER_H, 6, lineSegments  '   border segments
    DEFINE CHAR PATT_IDX_BORDER_H + 130, 4, lineSegmentJoiners
    DEFINE CHAR PATT_IDX_SLIDER, 1, sliderButton
    DEFINE CHAR 148, 1, palBlock

    DEFINE CHAR PATT_IDX_BOX_TL, 4, palBox
    DEFINE CHAR PATT_IDX_BOX_TL + 128, 4, palBox

    DEFINE CHAR PATT_IDX_SELECTED_L, 2, highlightLeft   ' ends of selection bar

    DEFINE SPRITE 8, 1, sliderButtonH

    SPRITE FLICKER OFF
    END

' PICO9918 logo pattern
logo:
    DATA BYTE $01, $1f, $3f, $7f, $ff, $00, $8c, $00
    DATA BYTE $ff, $00, $00, $03, $01, $01, $03, $03
    DATA BYTE $c3, $e3, $f3, $e0, $00, $e0, $e0, $e1
    DATA BYTE $e3, $22, $e3, $e7, $00, $1f, $7f, $17
    DATA BYTE $00, $f8, $e0, $c0, $c0, $ff, $fe, $fc
    DATA BYTE $f8, $70, $00, $00, $03, $0f, $1f, $8a
    DATA BYTE $33, $3e, $3e, $16, $00, $60, $c0, $0e
    DATA BYTE $80, $f0, $fc, $10, $fe, $fe, $3f, $12
    DATA BYTE $07, $18, $20, $03, $20, $41, $42, $41
    DATA BYTE $20, $ff, $a8, $4b, $01, $17, $60, $10
    DATA BYTE $00, $08, $05, $85, $85, $04, $1f, $60
    DATA BYTE $80, $01, $80, $07, $08, $07, $80, $fe
    DATA BYTE $01, $08, $17, $fc, $02, $fe, $04, $81
    DATA BYTE $42, $11, $24, $17, $10, $00, $fc, $04
    DATA BYTE $33, $00, $84, $00, $86, $1f, $83, $84
    DATA BYTE $43, $93, $37, $1f, $fc, $b0, $37, $00
    DATA BYTE $20, $40, $ff, $ff, $ff, $ff, $c0

logo2:
    DATA BYTE $18, $ff, $00, $f8, $cc, $00, $06, $30
    DATA BYTE $fe, $00, $00, $f3, $e3, $39, $c3, $03
    DATA BYTE $00, $e7, $00, $00, $e3, $e3, $e1, $e0
    DATA BYTE $e0, $c0, $c0, $61, $e0, $1b, $7f, $1f
    DATA BYTE $d0, $1b, $21, $fc, $f8, $3e, $03, $3e
    DATA BYTE $3f, $1f, $1f, $0f, $03, $9d, $0e, $c0
    DATA BYTE $3b, $10, $0c, $3f, $fe, $16, $f0, $80
    DATA BYTE $18, $01, $07, $00, $07, $08, $10, $20
    DATA BYTE $3f, $5c, $24, $01, $2a, $04, $10, $84
    DATA BYTE $84, $08, $0f, $60, $80, $60, $82, $39
    DATA BYTE $1f, $20, $40, $80, $13, $10, $fe, $02
    DATA BYTE $fc, $16, $01, $fe, $10, $58, $10, $24
    DATA BYTE $0f, $00, $6c, $84, $00, $fc, $07, $40
    DATA BYTE $83, $84, $83, $80, $3a, $25, $fc, $1f
    DATA BYTE $37, $3a, $20, $10, $00, $37, $ff, $ff
    DATA BYTE $ff, $ff, $c0

highlightLeft:
    DATA BYTE $3F, $7F, $FF, $FF, $FF, $FF, $7F, $3F
highlightRight:
    DATA BYTE $FC, $FE, $FF, $FF, $FF, $FF, $FE, $FC

lineSegments:
    DATA BYTE $00, $00, $00, $ff, $ff, $00, $00, $00 ' horz
    DATA BYTE $18, $18, $18, $18, $18, $18, $18, $18 ' vert
    DATA BYTE $00, $00, $00, $07, $0F, $1C, $18, $18 ' tl
    DATA BYTE $00, $00, $00, $E0, $F0, $38, $18, $18 ' tr
    DATA BYTE $18, $18, $1C, $0F, $07, $00, $00, $00 ' bl
    DATA BYTE $18, $18, $38, $F0, $E0, $00, $00, $00 ' br

lineSegmentJoiners:
    DATA BYTE $00, $00, $00, $ff, $ff, $3c, $18, $18 ' hd
    DATA BYTE $18, $18, $3c, $ff, $ff, $00, $00, $00 ' hu
    DATA BYTE $18, $18, $38, $f8, $f8, $38, $18, $18 ' vl
    DATA BYTE $18, $18, $1c, $1f, $1f, $1c, $18, $18 ' vr

sliderButton:
    DATA BYTE $00, $3C, $7E, $FF, $FF, $7E, $3C, $00

sliderButtonH:
    DATA BYTE $3C, $42, $81, $81, $81, $81, $42, $3C
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00

palBox:
    DATA BYTE $3F, $51, $62, $44, $48, $51, $62, $44
    DATA BYTE $FC, $12, $22, $46, $8A, $12, $22, $46
    DATA BYTE $48, $51, $62, $44, $48, $51, $3F, $00
    DATA BYTE $8A, $12, $22, $46, $8A, $12, $FC, $00

horzBar:
    DATA BYTE PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H
    DATA BYTE PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H
    DATA BYTE PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H
    DATA BYTE PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H,PATT_IDX_BORDER_H

vBar:
DATA BYTE PATT_IDX_BORDER_V ' intentional flow through
emptyRow:
    DATA BYTE "                                "

font:   ' pletter compressed font data (32-127)
    DATA BYTE $3e, $00, $39, $00, $18, $00, $00, $2d
    DATA BYTE $01, $6c, $00, $25, $0f, $06, $fe, $01
    DATA BYTE $40, $0b, $11, $7e, $c0, $7c, $06, $fc
    DATA BYTE $40, $18, $10, $c6, $cc, $18, $30, $66
    DATA BYTE $00, $c6, $00, $38, $6c, $38, $76, $dc
    DATA BYTE $cc, $06, $76, $00, $30, $30, $60, $8a
    DATA BYTE $27, $0c, $15, $00, $2a, $18, $0c, $0f
    DATA BYTE $03, $00, $a0, $0b, $10, $66, $3c, $ff
    DATA BYTE $3c, $75, $66, $50, $39, $7d, $50, $5c
    DATA BYTE $c3, $18, $00, $7e, $00, $58, $6c, $00
    DATA BYTE $06, $a0, $2c, $41, $c0, $80, $00, $7c
    DATA BYTE $02, $ce, $de, $f6, $e6, $c6, $7c, $12
    DATA BYTE $65, $38, $7f, $32, $00, $0f, $c6, $06
    DATA BYTE $7c, $c0, $c0, $fe, $00, $05, $fc, $06
    DATA BYTE $06, $3c, $06, $78, $22, $5f, $cc, $00
    DATA BYTE $fe, $0c, $5f, $33, $fe, $c0, $11, $29
    DATA BYTE $27, $1c, $08, $c6, $57, $07, $0f, $0d
    DATA BYTE $57, $7a, $2f, $0c, $71, $02, $07, $7e
    DATA BYTE $06, $76, $3a, $5b, $f3, $03, $30, $b8
    DATA BYTE $66, $9f, $ee, $7e, $80, $33, $0b, $91
    DATA BYTE $38, $00, $a3, $71, $05, $ef, $25, $37
    DATA BYTE $de, $00, $c0, $19, $12, $d7, $40, $fe
    DATA BYTE $02, $ae, $77, $03, $02, $c5, $17, $c0
    DATA BYTE $00, $85, $57, $f8, $cc, $0d, $0a, $fa
    DATA BYTE $f8, $7f, $0d, $71, $f8, $97, $b3, $07
    DATA BYTE $c0, $46, $1f, $ce, $5d, $1f, $1d, $36
    DATA BYTE $46, $37, $ec, $c3, $bf, $06, $b8, $00
    DATA BYTE $17, $cc, $d8, $13, $f0, $d8, $cc, $17
    DATA BYTE $c0, $a8, $00, $37, $0f, $ee, $fe, $28
    DATA BYTE $fe, $d6, $27, $07, $e6, $f6, $55, $de
    DATA BYTE $37, $07, $3f, $d7, $00, $27, $6d, $6c
    DATA BYTE $4f, $13, $00, $d6, $de, $ea, $dd, $0f
    DATA BYTE $37, $8e, $5f, $7c, $47, $75, $ff, $57
    DATA BYTE $00, $dc, $67, $6a, $00, $d9, $36, $38
    DATA BYTE $d5, $07, $2f, $a0, $63, $07, $6c, $87
    DATA BYTE $ba, $00, $43, $15, $d6, $e0, $1e, $97
    DATA BYTE $f1, $23, $27, $3c, $30, $93, $00, $3c
    DATA BYTE $7f, $60, $84, $f1, $02, $0f, $0c, $e9
    DATA BYTE $00, $0f, $10, $5a, $2d, $2c, $d1, $00
    DATA BYTE $5e, $24, $24, $e5, $a5, $27, $6e, $7e
    DATA BYTE $c2, $8e, $af, $ff, $3a, $0f, $81, $2e
    DATA BYTE $7f, $cf, $2c, $16, $17, $e8, $0f, $fb
    DATA BYTE $81, $0f, $1c, $36, $30, $78, $30, $67
    DATA BYTE $02, $0f, $46, $16, $ae, $99, $2e, $7f
    DATA BYTE $74, $44, $c0, $3c, $9b, $2f, $00, $34
    DATA BYTE $80, $17, $80, $e3, $bb, $a7, $15, $4c
    DATA BYTE $17, $00, $cc, $80, $59, $d6, $07, $b7
    DATA BYTE $2f, $70, $4f, $ff, $00, $f1, $81, $f2
    DATA BYTE $4f, $3e, $b9, $0f, $f9, $ee, $5f, $f8
    DATA BYTE $f6, $c6, $cc, $18, $0e, $0f, $ee, $36
    DATA BYTE $87, $36, $ff, $3b, $07, $8c, $ff, $07
    DATA BYTE $e7, $80, $6b, $17, $3f, $0b, $b8, $ad
    DATA BYTE $60, $38, $ff, $3f, $01, $60, $cf, $d8
    DATA BYTE $d8, $cf, $60, $3f, $cf, $bb, $63, $03
    DATA BYTE $87, $96, $00, $f1, $76, $78, $dc, $f8
    DATA BYTE $79, $00, $ff, $ff, $ff, $ff, $80

#if SPRITE_TEST

logoSprites: ' pletter compressed logo sprites for 'scanline sprites' demo
    DATA BYTE $00, $3f, $7f, $ff, $00, $00, $ff, $93
    DATA BYTE $00, $e0, $00, $00, $80, $00, $e0, $f8
    DATA BYTE $fc, $3c, $3c, $fc, $1e, $f8, $f0, $00
    DATA BYTE $35, $00, $f0, $9a, $00, $00, $f2, $00
    DATA BYTE $0f, $40, $60, $f0, $3b, $f0, $7f, $3f
    DATA BYTE $68, $0f, $0f, $f8, $bd, $0d, $3f, $07
    DATA BYTE $b0, $1f, $5f, $1e, $0e, $96, $00, $1e
    DATA BYTE $62, $c0, $1f, $3f, $40, $8f, $90, $8f
    DATA BYTE $31, $40, $3f, $07, $ff, $b0, $6f, $08
    DATA BYTE $c4, $24, $03, $e4, $04, $e4, $24, $c4
    DATA BYTE $08, $61, $6f, $3c, $44, $84, $68, $0c
    DATA BYTE $00, $3c, $dd, $39, $7f, $3f, $4f, $e7
    DATA BYTE $43, $cc, $3f, $c8, $03, $fb, $3f, $ff
    DATA BYTE $ff, $ff, $ff

logoSpriteWidths:
    DATA BYTE 14, 4, 13, 15, 14, 6, 14
  
sine: ' sine wave values for scanline sprite animation
    DATA BYTE $10, $10, $11, $11, $12, $12, $12, $13
    DATA BYTE $13, $13, $14, $14, $14, $15, $15, $15
    DATA BYTE $16, $16, $16, $16, $17, $17, $17, $17
    DATA BYTE $17, $18, $18, $18, $18, $18, $18, $18
    DATA BYTE $18, $18, $18, $18, $18, $18, $18, $18
    DATA BYTE $17, $17, $17, $17, $17, $16, $16, $16
    DATA BYTE $16, $15, $15, $15, $14, $14, $14, $13
    DATA BYTE $13, $13, $12, $12, $12, $11, $11, $10
    DATA BYTE $10, $10, $0F, $0F, $0E, $0E, $0E, $0D
    DATA BYTE $0D, $0D, $0C, $0C, $0C, $0B, $0B, $0B
    DATA BYTE $0A, $0A, $0A, $0A, $09, $09, $09, $09
    DATA BYTE $09, $08, $08, $08, $08, $08, $08, $08
    DATA BYTE $08, $08, $08, $08, $08, $08, $08, $08
    DATA BYTE $09, $09, $09, $09, $09, $0A, $0A, $0A
    DATA BYTE $0A, $0B, $0B, $0B, $0C, $0C, $0C, $0D
    DATA BYTE $0D, $0D, $0E, $0E, $0E, $0F, $0F, $10

#endif

pow2: ' 1 << INDEX
    DATA BYTE $01, $02, $04, $08, $10, $20, $40, $80

block:
    DATA BYTE $FE, $FE, $FE, $FE, $FE, $FE, $FE, $00
palBlock:
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00    