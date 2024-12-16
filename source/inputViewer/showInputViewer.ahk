#Requires AutoHotkey v1

showInputViewer() {
    global isInputViewerOpen, global enabledGameControls
    if isInputViewerOpen {
        Gui, inputViewerWindow:Show
    } else {
        constructInputViewerWindow()
        IniRead, viewerWindowWidth, viewer-layout.ini, fairbox-input-viewer-window, % "Width"
        IniRead, viewerWindowHeight, viewer-layout.ini, fairbox-input-viewer-window, % "Height"
        Gui, inputViewerWindow:Show, w%viewerWindowWidth% h%viewerWindowHeight%, % "Input Viewer - fairbox"
        isInputViewerOpen := true

        updateInputViewerEnabledControlsAlert(enabledGameControls)
        /*  to avoid triggering buttons with the keyboard when opening the
            input viewer with showInputViewer()
        */
        GuiControl, inputViewerWindow:Focus, inputViewerInvisibleText
    }

    return
}