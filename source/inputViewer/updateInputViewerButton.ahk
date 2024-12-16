#Requires AutoHotkey v1

updateInputViewerButton(hotkeyVarName) {
    global
    GuiControl, inputViewerWindow:, % "viewer" hotkeyVarName, % "hbitmap:*" (%hotkeyVarName% ? imgBtnPressHandle : imgBtnReleaseHandle)
}