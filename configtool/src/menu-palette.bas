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

paletteMenu: PROCEDURE


    VDP_DISABLE_INT

    DRAW_TITLE("PALETTE")

    DIM bmpBuf(64)

    FOR I = 0 TO 14
        bmpBuf(I * 2) = PATT_IDX_BOX_TL
        bmpBuf(I * 2 + 1) = PATT_IDX_BOX_TR
        bmpBuf(32 + I * 2) = PATT_IDX_BOX_BL
        bmpBuf(32 + I * 2 + 1) = PATT_IDX_BOX_BR
    NEXT I

    #addr = NAME_TAB_XY(1, 7)
    DEFINE VRAM #addr, 30, VARPTR bmpBuf(0)
    DEFINE VRAM #addr + 32, 30, VARPTR bmpBuf(32)

    FOR I = 0 TO 63
        bmpBuf(I) = 0
    NEXT I

    CONST BITMAP_WIDTH  = 16 * 15
    CONST BITMAP_HEIGHT = 13

    ' Bitmap layer
    ' Total VRAM required is:
    '   BITMAP_WIDTH / 4 * BITMAP_HEIGHT: 60 * 13 = 780 B
    VDP_REG(31) = $f0           ' bml en, pri, trans, fat, pal = 0
    VDP_REG(32) = $70           ' $1C00 >> 6 
    VDP_REG(33) = 10            ' x
    VDP_REG(34) = 57            ' y
    VDP_REG(35) = BITMAP_WIDTH  ' w
    VDP_REG(36) = BITMAP_HEIGHT ' h

    CONST PAL_SWATCH_STRIDE = (BITMAP_WIDTH / 4)


    FOR C = 1 TO 15
        col = C * 16 + C
        bmpBuf((C * 4) - 4) = col
        bmpBuf((C * 4) - 3) = col
        bmpBuf((C * 4) - 2) = col
    NEXT C

    FOR R = 0 TO 12
        DEFINE VRAM $1C00 + (R * PAL_SWATCH_STRIDE), PAL_SWATCH_STRIDE, VARPTR bmpBuf(0)
    NEXT R

    FOR currentIndex = 1 TO 15
        PUT_XY(currentIndex * 2 - 1, 6), hexChar(currentIndex)
        GOSUB checkDirty
    NEXT currentIndex

    bmpBuf(0) = PATT_IDX_BOX_TL
    bmpBuf(1) = PATT_IDX_BOX_TR
    bmpBuf(2) = PATT_IDX_BOX_BL
    bmpBuf(3) = PATT_IDX_BOX_BR
    bmpBuf(4) = PATT_IDX_BOX_TL + 128
    bmpBuf(5) = PATT_IDX_BOX_TR + 128
    bmpBuf(6) = PATT_IDX_BOX_BL + 128
    bmpBuf(7) = PATT_IDX_BOX_BR + 128

    PRINT AT XY(1,10), "Red:"
    PRINT AT XY(1,12), "Green:"
    PRINT AT XY(1,14), "Blue:"

    PRINT AT XY(26, 9) , "\5\5\5\5\5"
    PRINT AT XY(26, 15) , "\6\6\6\6\6"
    FOR I = 10 to 14
        PRINT AT XY(25, I) , "\3\148\148\148\148\148\4"
    NEXT I

    oldMenuTopRow = g_menuTopRow
    oldIndex = g_currentMenuIndex

    g_menuTopRow = MENU_TITLE_ROW + 13
    MENU_INDEX_OFFSET = 12
    MENU_INDEX_COUNT = 2
    MENU_START_X = 6
    g_currentMenuIndex = 0

    GOSUB renderMenu

    currentIndex = 1
    lastIndex = 15

    currentMenu = 0 ' 0 = pal, 1 = r, 2 = g, 3 = b
    lastMenu    = 0
    DIM rgb(3)

    ' horz bar settings
    BX = 8
    BW = 16

    VDP_ENABLE_INT
    
    DIM currentColor(2)

    WHILE 1

        WAIT
        VDP_DISABLE_INT

        IF currentMenu = 0 THEN
            #addr = NAME_TAB_XY(currentIndex * 2 - 1, 7)
            DEFINE VRAM #addr, 2, VARPTR bmpBuf(0 + (FRAME AND 8) / 2)
            DEFINE VRAM #addr + 32, 2, VARPTR bmpBuf(2 + (FRAME AND 8) / 2)
            IF lastIndex <> currentIndex THEN GOSUB updateRGB
        ELSEIF currentMenu < 4 THEN
                SPRITE 0, 8 * (8 + (currentMenu * 2)) - 1, 8 * (8 + rgb(currentMenu - 1)),32,(FRAME AND 8)+7

                cc1 = rgb(1) * 16 + rgb(2)
                IF currentColor(0) <> rgb(0) OR currentColor(1) <> cc1 THEN

                    I = currentMenu - 1
                    GOSUB renderSlider

                    currentColor(0) = $f0 OR rgb(0)
                    currentColor(1) = cc1

                    VDP_REG(47) = $c0 + currentIndex' palette data port from pal 2 index #10
                    DEFINE VRAM 0, 2, VARPTR currentColor(0)
                    VDP_REG(47) = $c0 + 16 + 1 ' palette data port from pal 2 index #10
                    DEFINE VRAM 0, 2, VARPTR currentColor(0)
                    VDP_REG(47) = $40

                    ' update config palette
                    IDX = 128 + currentIndex * 2
                    VDP_CONFIG(IDX) = currentColor(0)
                    VDP_CONFIG(IDX + 1) = currentColor(1)

                    GOSUB checkDirty

                    tempConfigValues(IDX) = currentColor(0)
                    tempConfigValues(IDX + 1) = currentColor(1)


                    GOSUB delay
                END IF
        END IF
        
        VDP_ENABLE_INT

        IF lastMenu <> currentMenu THEN
            GOSUB delay
            lastMenu = currentMenu
        END IF

        GOSUB updateNavInput

        IF (CONT1.KEY > 0 AND CONT1.KEY < 3) THEN
            currentMenu = CONT1.KEY + 3
            g_nav = NAV_OK
        END IF

        IF currentMenu = 0 THEN
            IF NAV(NAV_LEFT) THEN
                currentIndex = currentIndex - 1
                if currentIndex = 0 THEN currentIndex = 15
            ELSEIF NAV(NAV_RIGHT) THEN
                currentIndex = currentIndex + 1
                if currentIndex > 15 THEN currentIndex = 1
            ELSEIF NAV(NAV_DOWN) THEN
                currentMenu = currentMenu + 1
                DEFINE VRAM NAME_TAB_XY(currentIndex * 2 - 1, 7), 2, VARPTR bmpBuf(0 + 4)
                DEFINE VRAM NAME_TAB_XY(currentIndex * 2 - 1, 8), 2, VARPTR bmpBuf(2 + 4)
            ELSEIF NAV(NAV_UP) THEN
                currentMenu = (3 + MENU_INDEX_COUNT)
            END IF

        ELSEIF currentMenu < 4 THEN
            rgbIndex = currentMenu - 1
            IF NAV(NAV_DOWN) THEN
                currentMenu = currentMenu + 1
                GOSUB hideSprites
            ELSEIF NAV(NAV_UP) THEN
                currentMenu = currentMenu - 1
                GOSUB hideSprites
            ELSEIF NAV(NAV_LEFT) AND rgb(rgbIndex) > 0 THEN
                rgb(rgbIndex) = rgb(rgbIndex) - 1
            ELSEIF NAV(NAV_RIGHT) AND rgb(rgbIndex) < 15 THEN
                rgb(rgbIndex) = rgb(rgbIndex) + 1
            ELSEIF g_key > 0 AND g_key < 16 THEN
                rgb(rgbIndex) = g_key
            END IF
        ELSE
            IF NAV(NAV_DOWN) THEN
                currentMenu = currentMenu + 1
                IF (currentMenu > (3 + MENU_INDEX_COUNT)) THEN currentMenu = 0
            ELSEIF NAV(NAV_UP) THEN
                currentMenu = currentMenu - 1
            ELSEIF g_nav THEN
                IF currentMenu = 4 THEN' reset
                    GOSUB resetPalette
                ELSEIF currentMenu = 5 THEN' back
                    g_nav = NAV_CANCEL
                END IF
            END IF
        END IF

        cm = currentMenu + MENU_INDEX_OFFSET - 4
        IF g_currentMenuIndex <> cm THEN
            g_currentMenuIndex = cm
            GOSUB renderMenu
        END IF

        IF NAV(NAV_CANCEL) THEN EXIT WHILE
    WEND

    VDP_REG(31) = $00   ' bml en, pri, trans, fat, pal = 0
    
    GOSUB hideSprites

    g_paletteDirty = FALSE
    FOR I = 128 to 159
        IF tempConfigValues(I) <> savedConfigValues(I) THEN
            g_paletteDirty = TRUE
            EXIT FOR
        END IF
    NEXT I

    g_menuTopRow = oldMenuTopRow
    g_currentMenuIndex = oldIndex

    SET_MENU(MENU_ID_MAIN)
    END

updateRGB: PROCEDURE
    #addr = NAME_TAB_XY(currentIndex * 2 - 1, 7)
    DEFINE VRAM #addr, 2, VARPTR bmpBuf(0 + 4)
    DEFINE VRAM #addr + 32, 2, VARPTR bmpBuf(2 + 4)
    IF lastIndex > 0 THEN
        #addr = NAME_TAB_XY(lastIndex * 2 - 1, 7)
        DEFINE VRAM #addr, 2, VARPTR bmpBuf(0)
        DEFINE VRAM #addr + 32, 2, VARPTR bmpBuf(2)
    END IF

    I = 128 + currentIndex * 2

    currentColor(0) = tempConfigValues(I)
    currentColor(1) = tempConfigValues(I + 1)

    rgb(0) = currentColor(0) AND $0f
    rgb(1) = currentColor(1) / 16
    rgb(2) = currentColor(1) AND $0f

    ' update live palette
    VDP_REG(47) = $c0 + 16 + 1 ' palette data port from pal 2 index #10
    DEFINE VRAM 0, 2, VARPTR currentColor(0)
    VDP_REG(47) = $40

    GOSUB renderSliders                

    lastIndex = currentIndex

    GOSUB delay
    END

checkDirty: PROCEDURE
    PUT_XY(currentIndex * 2, 6), " "
    IDX = 128 + currentIndex * 2
    IF (tempConfigValues(IDX) <> savedConfigValues(IDX)) OR tempConfigValues(IDX + 1) <> savedConfigValues(IDX + 1) THEN
        PUT_XY(currentIndex * 2, 6), "*"
    END IF
    END

sliderPos:
    DATA BYTE 10,12,14

renderSlider: PROCEDURE
    BR = sliderPos(I)
    GOSUB horzBarRWX
    PUT_XY(8 + rgb(I), BR), PATT_IDX_SLIDER

    PRINT AT XY(27, 12), CHR$(hexChar(rgb(0))), CHR$(hexChar(rgb(1))), CHR$(hexChar(rgb(2)))
    END

renderSliders: PROCEDURE
    FOR I = 0 to 2
        GOSUB renderSlider
    NEXT I
    END

resetPalette: PROCEDURE
    WAIT

    GOSUB hideSprites

    VDP_REG(47) = $c0 ' palette data port from pal 2 index #10
    DEFINE VRAM 0, 32, defPal
    DEFINE VRAM 0, 32, defPal
    VDP_REG(47) = $40

    ' update config palette
    FOR I = 0 TO 31
        VDP_CONFIG(128 + I) = defPal(I)
        tempConfigValues(128 + I) = defPal(I)
    NEXT I

    I = currentIndex
    FOR currentIndex = 1 TO 15
        GOSUB checkDirty
    NEXT currentIndex
    currentIndex = I

    lastIndex = 0
    GOSUB updateRGB

    END

defPal:
  DATA BYTE $00, $00
  DATA BYTE $F0, $00
  DATA BYTE $F2, $C3
  DATA BYTE $F5, $D6
  DATA BYTE $F5, $4F
  DATA BYTE $F7, $6F
  DATA BYTE $FD, $54
  DATA BYTE $F4, $EF
  DATA BYTE $FF, $54
  DATA BYTE $FF, $76
  DATA BYTE $FD, $C3
  DATA BYTE $FE, $D6
  DATA BYTE $F2, $B2
  DATA BYTE $FC, $5C
  DATA BYTE $FC, $CC
  DATA BYTE $FF, $FF

