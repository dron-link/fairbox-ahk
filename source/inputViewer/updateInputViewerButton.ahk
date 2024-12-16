#Requires AutoHotkey v1

updateInputViewerButton(hotkeyVarName) {
    global
    if isInputViewerOpen {
        GuiControl, inputViewerWindow:, % "viewer" hotkeyVarName, % "hbitmap:*" (%hotkeyVarName% ? imgBtnPressHandle : imgBtnReleaseHandle)
        /*  to avoid triggering buttons with the keyboard when opening the
            input viewer with showInputViewer()
        */
        GuiControl, inputViewerWindow:Focus, inputViewerInvisibleText
    }
    return
}