#Requires AutoHotkey v1.1

/*  The KeyName parameter specifies one or more keys that are either not recognized or 
    not supported by the current keyboard layout/language.
*/
KEY_NAME_ERROR := 2

; the script depends on the order of these: a remnant of the old design. don't alter it except to append
; a new element.
hotkeys := [ "Analog Up" ; 1
    , "Analog Down" ; 2
    , "Analog Left" ; 3
    , "Analog Right" ; 4
    , "ModX" ; 5
    , "ModY" ; 6
    , "A" ; 7
    , "B" ; 8
    , "L" ; 9
    , "R" ; 10
    , "X" ; 11
    , "Y" ; 12
    , "Z" ; 13
    , "C-stick Up" ; 14
    , "C-stick Down" ; 15
    , "C-stick Left" ; 16
    , "C-stick Right" ; 17
    , "Light Shield" ; 18
    , "Mid Shield" ; 19
    , "Start" ; 20
    , "D-pad Up" ; 21
    , "D-pad Down" ; 22
    , "D-pad Left" ; 23
    , "D-pad Right" ; 24
    , "Debug" ; 25
    , "Input On/Off"] ; 26

; named values------------------------------------------------------------------------------

/*  P_X, U_X and BITS_SDI_X technique values indicate a trace of technique and must be different to 0,
    as 0 (false) will fulfill the role of "no technique"
*/
P_RIGHTLEFT := 1 ; id: right to left empty pivot
P_LEFTRIGHT := 2 ; id: left to right pivot
U_YES := 1 ; id: uncrouch
ZONE_CENTER := 0 ; id: in the zone of analog stick neutral
ZONE_U := 1 ; 0b0000'0001
ZONE_D := 1<<1 ; 0b0000'0010
ZONE_L := 1<<2 ; 0b0000'0100
ZONE_R := 1<<3 ; 0b0000'1000
; for bitwise calculations:
ZONE_DIR := ((1<<4) - 1) ; 0b0000'1111
BITS_SDI := ((1<<4) - 1) << 4 ; 0b1111'0000
BITS_SDI_QUARTERC := 1<<4 ; 0b0001'0000
BITS_SDI_TAP_CARD := 1<<5 ; 0b0010'0000
BITS_SDI_TAP_DIAG := 1<<6
BITS_SDI_TAP_CRDG := 1<<7
; direction types per sdi popcount
POP_CENTER := 0, POP_CARD := 1, POP_DIAG := 2

; coordinate components simple array keys
xComp := 1, yComp := 2

; window titles to use in commands like     Gui, % controlsWindow ":Add", ... 
;controlsWindow := "controlsWindow"
;inputViewerWindow := "inputViewerWindow"
;settingsWindow := "settingsWindow"
;mainMenuWindow := "mainMenuWindow"
