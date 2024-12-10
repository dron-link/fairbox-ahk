#Requires AutoHotkey v1.1.37.02
#Warn All, OutputDebug
#SingleInstance force
#NoEnv
#include %A_ScriptDir%\test\logAppend.ahk

SetWorkingDir, %A_ScriptDir%

;https://www.autohotkey.com/boards/viewtopic.php?t=23276
FormatTime, datestring, %A_Now% L0009     
logAppend(datestring "`n")

RunWait, test\zzRange.ahk
RunWait, test\testGetFuzzyHorizontal100.ahk

logAppend("all tests finish")

FileCreateDir, fairbox_log
FileMove, % "fairbox_log_0.log", % "fairbox_log\fairbox_log_" A_Now ".log"

return