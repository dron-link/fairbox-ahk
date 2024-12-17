#Requires AutoHotkey v1

showInputViewer() {
    global isInputViewerOpen
    if isInputViewerOpen {
        Gui, inputViewerWindow:Show
    } else {
        constructInputViewerWindow()
        isInputViewerOpen := true   
    }
    /*  to avoid triggering buttons with the keyboard when opening the
        input viewer with showInputViewer()
    */
    GuiControl, inputViewerWindow:Focus, inputViewerInvisibleText

    return
}