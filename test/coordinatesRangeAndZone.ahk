#Requires AutoHotkey v1
#Warn All, MsgBox

#include %A_WorkingDir%\source\analogZoneInfo\crouchRange\getIsInCrouchRange.ahk
#include %A_WorkingDir%\source\analogZoneInfo\dashZone\getDashZoneOf.ahk
#include %A_WorkingDir%\source\analogZoneInfo\outOfDeadzone\getIsOutOfDeadzoneDown.ahk
#include %A_WorkingDir%\source\analogZoneInfo\outOfDeadzone\getIsOutOfDeadzoneUp.ahk

#include %A_WorkingDir%\source\system\gameEngineConstants.ahk

#include %A_WorkingDir%\logAppend.ahk

logAppend("coordinatesRangeAndZone")
logAppend(A_LineFile "`n")

if getIsOutOfDeadzoneUp(22) {
    logAppend("getIsOutOfDeadzoneUp(22) at line " A_LineNumber)
}
if !getIsOutOfDeadzoneUp(23) {
    logAppend("!getIsOutOfDeadzoneUp(23) at line " A_LineNumber)
}

if getIsOutOfDeadzoneDown(-22) {
    logAppend("getIsOutOfDeadzoneDown(-22) at line " A_LineNumber)
}
if !getIsOutOfDeadzoneDown(-23) {
    logAppend("!getIsOutOfDeadzoneDown(-23) at line " A_LineNumber)
}

if getIsInCrouchRange(-49) {
    logAppend("getIsInCrouchRange(-49) at line " A_LineNumber)
}

if !getIsInCrouchRange(-50) {
    logAppend("!getIsInCrouchRange(-50) at line " A_LineNumber)
}

itemL := {}
itemR := {}
ZONE_L := itemL ; getDashZoneOf(aX) uses these two globals...
ZONE_R := itemR

if getDashZoneOf(-63) {
    logAppend("getDashZoneOf(-63) at line " A_LineNumber)
}
if getDashZoneOf(63) {
    logAppend("getDashZoneOf(63) at line " A_LineNumber)
}

if (itemL != getDashZoneOf(-64)) {
    logAppend("itemL != getDashZoneOf(-64) at line " A_LineNumber)
}
if (itemR != getDashZoneOf(64)) {
    logAppend("itemR != getDashZoneOf(64) at line " A_LineNumber)
}

logAppend("coordinatesRangeAndZone finish`n")