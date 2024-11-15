#Requires AutoHotkey v1.1

constructMainsTrayMenu() {
    Menu, Tray, Add, % "Edit Controls", mainIntoControlsWindow
    Menu, Tray, Default, % "Edit Controls"
    Menu, Tray, Click, 1
    return
}

mainIntoControlsWindow() {
    global enabledGameControls
    IniWrite, % True, config.ini, LaunchMode, MainIntoControlsWindow
    IniWrite, % enabledGameControls, config.ini, LaunchMode, ControlsEnabledRecall
    Run, StandaloneControlsEditor.ahk, % A_ScriptDir, UseErrorLevel
    If (ErrorLevel = "ERROR") {
        Run, StandaloneControlsEditor.exe, % A_ScriptDir, UseErrorLevel
        If (ErrorLevel = "ERROR") {
            MsgBox, % "Couldn't open the Controls Editor. " A_ScriptDir "\StandaloneControlsEditor.*"
        }
    } 

    ; ExitApp

    return
}