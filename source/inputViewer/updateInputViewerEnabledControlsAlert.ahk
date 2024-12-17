#Requires AutoHotkey v1

updateInputViewerEnabledControlsAlert(state) {
    guiFontDefault("inputViewerWindow")
        guiControl, Font, inputViewerEnabledControlsAlert
        if state {
            GuiControl, inputViewerWindow:, inputViewerEnabledControlsAlert, % ""
        } else {
            ; turn the text red
            Gui, inputViewerWindow:Font, cRed 
            GuiControl, inputViewerWindow:Font, inputViewerEnabledControlsAlert

            GuiControl, inputViewerWindow:, inputViewerEnabledControlsAlert, % "fairbox is disabled. Reenable it with the Input On/Off key."
        }
    return
}