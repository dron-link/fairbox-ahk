#Requires AutoHotkey v1.1.37.02
#SingleInstance force
#Warn All, OutputDebug

; exit an active script
DetectHiddenWindows, On
        ;    0x111 = WN_COMMAND code
        ;           65307 = exit code
PostMessage, 0x111, 65307 ,,, %A_ScriptDir%\fairbox.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairbox.exe
DetectHiddenWindows, Off

#include %A_ScriptDir%\source\fairbox.ahk