#Requires AutoHotkey v1.1.37.02
#Warn All, OutputDebug
#SingleInstance force
#NoEnv
#include %A_ScriptDir%\logAppend.ahk

logDate() {
    ;https://www.autohotkey.com/boards/viewtopic.php?t=23276
    FormatTime, datestring, %A_Now% L0009     
    logAppend(datestring "`n")
}
logDate()

SetWorkingDir, %A_ScriptDir%

; RunWait commands here
RunWait, test\pivotDetection.ahk

logAppend("all tests finish")

; rename and relocate:  fairbox_log_0.log  =>  fairbox_log\fairbox_log_YYYYMMDDHHmmss.log 
FileCreateDir, fairbox_log
FileMove, % "fairbox_log_0.log", % "fairbox_log\fairbox_log_" A_Now ".log"

return