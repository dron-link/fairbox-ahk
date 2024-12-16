#Requires AutoHotkey v1

updateInputViewerEnabledControlsAlert(status) {
    global isInputViewerOpen ;, global inputViewerEnabledControlsAlert
    if isInputViewerOpen {
        guiFontDefault("inputViewerWindow")
        guiControl, Font, inputViewerEnabledControlsAlert
        if status {
            GuiControl, inputViewerWindow:, inputViewerEnabledControlsAlert, % ""
        } else {
            ; turn the text red
            Gui, inputViewerWindow:Font, cRed 
            GuiControl, inputViewerWindow:Font, inputViewerEnabledControlsAlert

            GuiControl, inputViewerWindow:, inputViewerEnabledControlsAlert, % "fairbox is disabled. Reenable it with the Input On/Off key."
        }
    }
    return
}