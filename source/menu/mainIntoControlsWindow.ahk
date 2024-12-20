#Requires AutoHotkey v1

mainIntoControlsWindow() {
    global enabledGameControls
    IniWrite, % True, config.ini, LaunchMode, MainIntoControlsWindow
    IniWrite, % enabledGameControls, config.ini, LaunchMode, EnabledControlsRecall
    Run, fairboxControlsEditor.ahk, % A_ScriptDir, UseErrorLevel
    If (ErrorLevel = "ERROR") {
        Run, fairboxControlsEditor.exe, % A_ScriptDir, UseErrorLevel
        If (ErrorLevel = "ERROR") {
            MsgBox, % "Couldn't open the Controls Editor. " A_ScriptDir "\fairboxControlsEditor.*"
        }
    } 
    ; if the controls editor runs, it will close this script now.

    return
}