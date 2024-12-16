#Requires AutoHotkey v1

constructControlsEditorTrayMenu() {
    Menu, Tray, Add, % "Open fairbox", LabelOpenMain
    Menu, Tray, Add, % "Input Viewer", LabelOpenInputViewer
    Menu, Tray, Add, % "Edit Controls", showControlsWindow
    Menu, Tray, Default, % "Edit Controls"
    Menu, Tray, Click, 1
    
    return
}

