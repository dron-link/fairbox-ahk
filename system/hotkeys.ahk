#Requires AutoHotkey v1.1

; state variables
; usage: if true, the hotkey is pressed
buttonUp := false
buttonDown := false
buttonLeft := false
buttonRight := false

buttonModX := false
buttonModY := false

buttonA := false
buttonB := false
buttonL := false
buttonR := false
buttonX := false
buttonY := false
buttonZ := false

buttonCUp := false
buttonCDown := false
buttonCLeft := false
buttonCRight := false

buttonLightShield := false
buttonMidShield := false

buttonStart := false

buttonDPadUp := false
buttonDPadDown := false
buttonDPadLeft := false
buttonDPadRight := false

legacyDebugKey := false
inputToggleKey := false

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
