#Requires AutoHotkey v1.1

; named values------------------------------------------------------------------------------

/*  P_X, and BITS_SDI_X technique values indicate a trace of technique and must be different to 0,
    as 0 (false) will fulfill the role of "no technique"
*/
P_RIGHTLEFT := 1 ; id: right to left empty pivot
P_LEFTRIGHT := 2 ; id: left to right pivot
BITS_SDI := ((1<<4) - 1) << 4 ; 0b1111'0000
BITS_SDI_QUARTERC := 1<<4 ; 0b0001'0000
BITS_SDI_TAP_CARD := 1<<5 ; 0b0010'0000
BITS_SDI_TAP_DIAG := 1<<6
BITS_SDI_TAP_CRDG := 1<<7

ZONE_U := 1 ; 0b0000'0001
ZONE_D := 1<<1 ; 0b0000'0010
ZONE_L := 1<<2 ; 0b0000'0100
ZONE_R := 1<<3 ; 0b0000'1000
; for bitwise calculations:
ZONE_DIR := ((1<<4) - 1) ; 0b0000'1111

; direction types per sdi popcount
POP_CENTER := 0, POP_CARD := 1, POP_DIAG := 2

; coordinate components simple array keys
xComp := 1, yComp := 2

; window titles to use in commands like     Gui, % controlsWindow ":Add", ... 
;controlsWindow := "controlsWindow"
;inputViewerWindow := "inputViewerWindow"
;settingsWindow := "settingsWindow"
;mainMenuWindow := "mainMenuWindow"
