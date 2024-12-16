#Requires AutoHotkey v1

constructMainsTrayMenu() {
    Menu, Tray, Add, % "Input Viewer", showInputViewer
    Menu, Tray, Add, % "Edit Controls", mainIntoControlsWindow
    Menu, Tray, Default, % "Edit Controls"
    Menu, Tray, Click, 1
    return
}