#Requires AutoHotkey v1.1

showControlsWindow() {
    Gui, controlsWindow:Show,, % "Controls Editor - fairbox"
    ; prevents immediately waiting for input on the 1st input box (assoc variable HK1) when showing gui
    GuiControl, controlsWindow:Focus, gameBtName1
    return
}