#Requires AutoHotkey v1.1

hotkeyCtrlHasFocus() {
    global
    OutputDebug, % "HotkeyCtrlHasFocus ran " A_TickCount " `n"
    ;Retrieves the control ID (ClassNN) for the control that currently has focus
    GuiControlGet, vCurrentControlID, Focus

    If (InStr(vCurrentControlID, "hotkey")) {
        GuiControlGet, vCurrentControlAssociatedVarName, FocusV
        Return vCurrentControlAssociatedVarName
    }
    Return
}

hotkeyCtrlHasFocusIsSpecial() {
    global
    OutputDebug, % "HotkeyCtrlHasFocusIsSpecial ran " A_TickCount " `n"
    ;Retrieves the control ID (ClassNN) for the control that currently has focus
    GuiControlGet, vCurrentControlID, Focus

    If (InStr(vCurrentControlID, "hotkey")) {
        GuiControlGet, vCurrentControlAssociatedVarName, FocusV
        hotkeyIndex := SubStr(vCurrentControlAssociatedVarName, 3)
        OutputDebug, % "hotkeyIndex " hotkeyIndex " isSpecialKey " isSpecialKey%hotkeyIndex% "`n"
        If isSpecialKey%hotkeyIndex% {
            Return vCurrentControlAssociatedVarName
        }
    }
    Return
}