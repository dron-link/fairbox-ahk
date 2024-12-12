#Requires AutoHotkey v1.1.37.02
#SingleInstance force
#Warn All, OutputDebug

; exit an active script
DetectHiddenWindows, On
        ;    0x111 = WN_COMMAND code
        ;           65307 = exit code
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditor.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditor.exe
DetectHiddenWindows, Off

#include %A_ScriptDir%\source\fairboxControlsEditor.ahk