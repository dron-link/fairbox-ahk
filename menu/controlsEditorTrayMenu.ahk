#Requires AutoHotkey v1.1

constructControlsEditorTrayMenu() {
    Menu, Tray, Add, % "Edit Controls", showControlsWindow
    Menu, Tray, Default, % "Edit Controls"
    Menu, Tray, Click, 1
    Menu, Tray, Add, % "Play", LabelOpenMain
    return
}

