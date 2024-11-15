#Requires AutoHotkey v1.1

constructControlsEditorTrayMenu() {
    Menu, Tray, Add, % "Edit Controls", showControlsWindow
    Menu, Tray, Default, % "Edit Controls"
    Menu, Tray, Click, 1
    Menu, Tray, Add, % "Play", LabelManualGoToMainFairbox
    return
}

showControlsWindow() {
    Gui, controlsWindow:Show,, % "Controls Editor - fairbox"
    ; prevents immediately waiting for input on the 1st input box (assoc variable HK1) when showing gui
    GuiControl, controlsWindow:Focus, gameBtName1
    return
}