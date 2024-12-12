#Requires AutoHotkey v1
#Warn All, MsgBox

#Include %A_WorkingDir%\source\analogZoneInfo\crouchRange\crouchRangeHistoryEntry.ahk ; class
#Include %A_WorkingDir%\source\analogZoneInfo\crouchRange\getCurrentCrouchRangeInfo.ahk

; test double
#Include %A_WorkingDir%\sdouble\technique\uncrouch\getUncrouchDid.ahk

#Include %A_WorkingDir%\logAppend.ahk

logAppend("GetCurrentCrouchRangeInfo_implementationDemo")
logAppend(A_LineFile "`n")


; globals found inside functions
itemNewTime := {}, currentTimeMS := itemNewTime
returnGetUncrouchDid := {}
returnError := {}


; begin the checks
saved := {in : {}}
candidateObject := {}
if (saved != getCurrentCrouchRangeInfo(saved, candidateObject, saved.in)) {
    logAppend("saved != getCurrentCrouchRangeInfo(saved, candidate, saved.in) at line " A_LineNumber)
}

newRangeIn := {}
if (candidateObject != getCurrentCrouchRangeInfo(saved, candidateObject, newRangeIn)) {
    logAppend("candidateObject != getCurrentCrouchRangeInfo(saved, candidateObject, {}) at line " A_LineNumber)
}

; get new info and pick it apart
expectGetUncrouchDid_sav := saved.in ; these are the call parameters that we expect in getUncrouchDid
expectGetUncrouchDid_now := newRangeIn
presumedNewInfo := getCurrentCrouchRangeInfo(saved, "", newRangeIn)

if (presumedNewInfo.in != newRangeIn) {
    logAppend("presumedNewInfo.in != newRangeIn at line " A_LineNumber)
}

if (presumedNewInfo.timestamp != itemNewTime) {
    logAppend("presumedNewInfo.timestamp != itemNewTime at line " A_LineNumber)
}

if (presumedNewInfo.uncrouch != returnGetUncrouchDid) {
    logAppend("presumedNewInfo.uncrouch != returnGetUncrouchDid at line " A_LineNumber)
}

logAppend("GetCurrentCrouchRangeInfo_implementationDemo finish`n")