#Requires AutoHotkey v1.1.37.02
#SingleInstance force

; exit an active debug script
DetectHiddenWindows, On
        ;    0x111 = WN_COMMAND code
        ;           65307 = exit code
PostMessage, 0x111, 65307,,, %A_ScriptDir%\StandaloneControlsEditorDebug.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\StandaloneControlsEditorDebug.exe
DetectHiddenWindows, Off

#include %A_ScriptDir%\source\StandaloneControlsEditor.ahk