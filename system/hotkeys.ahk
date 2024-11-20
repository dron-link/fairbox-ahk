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

; %hotkeysList[index]% should resolve to the corresponding variable
hotkeysList := ["buttonUp", "buttonDown", "buttonLeft", "buttonRight", "buttonModX", "buttonModY"
    , "buttonA", "buttonB", "buttonL", "buttonR", "buttonX", "buttonY", "buttonZ"
    , "buttonCUp", "buttonCDown", "buttonCLeft", "buttonCRight"
    , "buttonLightShield", "buttonMidShield", "buttonStart"
    , "buttonDPadUp", "buttonDPadDown", "buttonDPadLeft", "buttonDPadRight"
    , "legacyDebugKey", "inputToggleKey"]
;

hotkeysDisplay := []
Loop, % hotkeysList.Length() {
    Switch hotkeysList[A_Index]
    {
        Case "buttonUp":
            hotkeysDisplay[A_Index] := "Analog Up button"
        Case "buttonDown":
            hotkeysDisplay[A_Index] := "Analog Down button"
        Case "buttonLeft":
            hotkeysDisplay[A_Index] := "Analog Left button"
        Case "buttonRight":
            hotkeysDisplay[A_Index] := "Analog Right button"
        Case "buttonModX":
            hotkeysDisplay[A_Index] := "ModX button"
        Case "buttonModY":
            hotkeysDisplay[A_Index] := "ModY button"
        Case "buttonA":
            hotkeysDisplay[A_Index] := "A button"
        Case "buttonB":
            hotkeysDisplay[A_Index] := "B button"
        Case "buttonL":
            hotkeysDisplay[A_Index] := "L button"
        Case "buttonR":
            hotkeysDisplay[A_Index] := "R button"
        Case "buttonX":
            hotkeysDisplay[A_Index] := "X button"
        Case "buttonY":
            hotkeysDisplay[A_Index] := "Y button"
        Case "buttonZ":
            hotkeysDisplay[A_Index] := "Z button"
        Case "buttonCUp":
            hotkeysDisplay[A_Index] := "C-stick Up button"
        Case "buttonCDown":
            hotkeysDisplay[A_Index] := "C-stick Down button"
        Case "buttonCLeft":
            hotkeysDisplay[A_Index] := "C-stick Left button"
        Case "buttonCRight":
            hotkeysDisplay[A_Index] := "C-stick Right button"
        Case "buttonLightShield":
            hotkeysDisplay[A_Index] := "Light Shield button"
        Case "buttonMidShield":
            hotkeysDisplay[A_Index] := "Mid Shield button"
        Case "buttonStart":
            hotkeysDisplay[A_Index] := "Start button"
        Case "buttonDPadUp":
            hotkeysDisplay[A_Index] := "D-pad Up button"
        Case "buttonDPadDown":
            hotkeysDisplay[A_Index] := "D-pad Down button"
        Case "buttonDPadLeft":
            hotkeysDisplay[A_Index] := "D-pad Left button"
        Case "buttonDPadRight":
            hotkeysDisplay[A_Index] := "D-pad Right button"
        Case "legacyDebugKey":
            hotkeysDisplay[A_Index] := "Debug"
        Case "inputToggleKey":
            hotkeysDisplay[A_Index] := "Input On/Off"
        Default:
            hotkeysDisplay[A_Index] := ""
    }
}
