#Requires AutoHotkey v1.1

hotkeyCtrlHasFocus() {
    global
    ; Retrieves the control ID (ClassNN) for the control that currently has focus
    GuiControlGet, vCurrentControlID, controlsWindow:Focus

    If InStr(vCurrentControlID, "hotkey") {
        GuiControlGet, vCurrentControlAssociatedVarName, controlsWindow:FocusV
        Return vCurrentControlAssociatedVarName
    }
    Return false
}

hotkeyCtrlHasFocusIsSpecial() {
    global
    ;Retrieves the control ID (ClassNN) for the control that currently has focus
    GuiControlGet, vCurrentControlID, controlsWindow:Focus

    If InStr(vCurrentControlID, "hotkey") {
        GuiControlGet, vCurrentControlAssociatedVarName, controlsWindow:FocusV
        hotkeyIndex := SubStr(vCurrentControlAssociatedVarName, 3)
        If isSpecialKey%hotkeyIndex% {
            Return vCurrentControlAssociatedVarName
        }
    }
    Return false
}