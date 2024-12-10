#Requires AutoHotkey v1
#include %A_ScriptDir%\test\logAppend.ahk

logDate() {
    ;https://www.autohotkey.com/boards/viewtopic.php?t=23276
    FormatTime, datestring, %A_Now% L0009 
    
    logAppend(datestring "`n")
}