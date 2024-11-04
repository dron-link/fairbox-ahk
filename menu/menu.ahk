#Requires AutoHotkey v1.1

trayAddEditControls() {
    Menu, Tray, Click, 1
    Menu, Tray, Add, % "Edit Controls", showControlsWindow
    Menu, Tray, Default, % "Edit Controls"
    return
}