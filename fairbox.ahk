#Requires AutoHotkey v1.1.37.02
#SingleInstance force

; optimizations from
; https://www.autohotkey.com/boards/viewtopic.php?t=6413
#KeyHistory 0
ListLines Off

; exit an active debug script
DetectHiddenWindows, On
        ;    0x111 = WN_COMMAND code
        ;           65307 = exit code
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxDebug.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxDebug.exe
DetectHiddenWindows, Off

#include %A_ScriptDir%\source\fairbox.ahk