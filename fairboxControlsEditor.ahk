#Requires AutoHotkey v1.1.37.02
#SingleInstance force

; exit an active debug script
DetectHiddenWindows, On
        ;    0x111 = WN_COMMAND code
        ;           65307 = exit code
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditorDebug.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditorDebug.exe
DetectHiddenWindows, Off

#include %A_ScriptDir%\source\fairboxControlsEditor.ahk