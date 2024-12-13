#Requires AutoHotkey v1
#Warn All, MsgBox

#include %A_WorkingDir%\source\technique\pivot\getAttemptedPivotDirection.ahk
#include %A_WorkingDir%\source\technique\pivot\pivotTimingCheck.ahk
#include %A_WorkingDir%\source\system\fairboxConstants.ahk
#include %A_WorkingDir%\logAppend.ahk

logAppend("pivotDetection")
logAppend(A_LineFile "`n")

; utility
zoneToString(zone) {
    global ZONE_L, global ZONE_R
    Switch zone
    {
        Case ZONE_L:
            return "ZONE_L"
        Case ZONE_R:
            return "ZONE_R"
        Case 0:
            return "0"
    }
    ; else
    MsgBox, % "zoneToString can't identify the following parameter: " zone "`n"
    return zone
}

pivotToString(pivot) {
    global P_RIGHTLEFT, global P_LEFTRIGHT
    Switch pivot
    {
        Case P_RIGHTLEFT:
            return "P_RIGHTLEFT"
        Case P_LEFTRIGHT:
            return "P_LEFTRIGHT"
        Case 0:
            return "0"
    }
    ; else
    MsgBox, % "pivotToString can't identify the following parameter: " pivot "`n"
    return pivot
}

logWeirdDirectionCase(dashZoneHist, dashZoneNow, out) {
    logAppend("getAttemptedPivotDirection([{zone: " zoneToString(dashZoneHist[1].zone) "}"
    . ", {zone: " zoneToString(dashZoneHist[2].zone) "}, {zone: " zoneToString(dashZoneHist[3].zone) "}]" 
    . ", " zoneToString(dashZoneNow) ") yields " pivotToString(out))
}

; stuff
zoneHist := [{zone: 0}, {zone: 0}, {zone: 0}]

; pivot to the left variation 1
zoneHist[1].zone := ZONE_L
zoneHist[2].zone := ZONE_R
; changes to zoneHist[3].zone shouldn't alter result
zoneHist[3].zone := 0
out := getAttemptedPivotDirection(zoneHist, 0)
if (out != P_RIGHTLEFT) { 
    logWeirdDirectionCase(zoneHist, 0, out)
}
zoneHist[3].zone := ZONE_L
out := getAttemptedPivotDirection(zoneHist, 0)
if (out != P_RIGHTLEFT) { 
    logWeirdDirectionCase(zoneHist, 0, out)
}
; not seen in reality
;zoneHist[3].zone := ZONE_R


; pivot to the left variation 2
zoneHist[1].zone := ZONE_L
zoneHist[2].zone := 0
zoneHist[3].zone := ZONE_R
out := getAttemptedPivotDirection(zoneHist, 0)
if (out != P_RIGHTLEFT) { 
    logWeirdDirectionCase(zoneHist, 0, out)
}

; pivot to the right variation 1
zoneHist[1].zone := ZONE_R
zoneHist[2].zone := ZONE_L
; changes to zoneHist[3].zone shouldn't change result
zoneHist[3].zone := 0
out := getAttemptedPivotDirection(zoneHist, 0)
if (out != P_LEFTRIGHT) { 
    logWeirdDirectionCase(zoneHist, 0, out)
}
; not seen in reality 
;zoneHist[3].zone := ZONE_L
zoneHist[3].zone := ZONE_R
out := getAttemptedPivotDirection(zoneHist, 0)
if (out != P_LEFTRIGHT) { 
    logWeirdDirectionCase(zoneHist, 0, out)
}

; pivot to the right variation 2
zoneHist[1].zone := ZONE_R
zoneHist[2].zone := 0
zoneHist[3].zone := ZONE_L
out := getAttemptedPivotDirection(zoneHist, 0)
if (out != P_LEFTRIGHT) { 
    logWeirdDirectionCase(zoneHist, 0, out)
}

; no pivot direction
; face left, variation 1
zoneHist[1].zone := ZONE_L
zoneHist[2].zone := 0
zoneHist[3].zone := ZONE_R
; cases
out := getAttemptedPivotDirection(zoneHist, ZONE_L)
if out {
    logWeirdDirectionCase(zoneHist, ZONE_L, out)
}
out := getAttemptedPivotDirection(zoneHist, ZONE_R)
if out {
    logWeirdDirectionCase(zoneHist, ZONE_R, out)
}

; no pivot direction
; face right, variation 1
zoneHist[1].zone := ZONE_R
zoneHist[2].zone := 0
zoneHist[3].zone := ZONE_L
; cases
out := getAttemptedPivotDirection(zoneHist, ZONE_L)
if out {
    logWeirdDirectionCase(zoneHist, ZONE_L, out)
}
out := getAttemptedPivotDirection(zoneHist, ZONE_R)
if out {
    logWeirdDirectionCase(zoneHist, ZONE_R, out)
}

; no pivot direction
; variation 2
zoneHist[2].zone := 0
; cases
zoneHist[1].zone := ZONE_L
zoneHist[3].zone := ZONE_L
out := getAttemptedPivotDirection(zoneHist, 0)
if out {
    logWeirdDirectionCase(zoneHist, 0, out)
}
zoneHist[1].zone := ZONE_R
zoneHist[3].zone := ZONE_R
out := getAttemptedPivotDirection(zoneHist, 0)
if out {
    logWeirdDirectionCase(zoneHist, 0, out)
}

; ----------------------------------------------------------------------------------- part 2
; ------------------------------------------------------------------------------------------
numToSumStr(num) {
    global TIMELIMIT_HALFFRAME, global TIMELIMIT_FRAME
    global TIMESTALE_PIVOT_INPUTSEQUENCE, global ONE_FRAME

    ; if one of those variables don't match the values here, 
    ; then my strings don't apply, cases need to be adjusted
    if (TIMELIMIT_HALFFRAME != 100 or TIMELIMIT_FRAME != 200
        or TIMESTALE_PIVOT_INPUTSEQUENCE != 1000 or ONE_FRAME != 200) {
        return num
    }
    
    Switch num
    {
        Case 0:
            return "0"
        Case 1:
            return "1"
        Case 99:
            return "TIMELIMIT_HALFFRAME - 1"
        Case 100:
            return "TIMELIMIT_HALFFRAME"
        Case 300:
            return "TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME"
        Case 301:
            return "TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME + 1"
        Case 800:
            return "TIMESTALE_PIVOT_INPUTSEQUENCE - ONE_FRAME"
        Case 801:
            return "TIMESTALE_PIVOT_INPUTSEQUENCE - ONE_FRAME + 1"
        Case 1000:
            return "TIMESTALE_PIVOT_INPUTSEQUENCE"
        Case 1001:
            return "TIMESTALE_PIVOT_INPUTSEQUENCE + 1"
    }
    ; else
    MsgBox, % "numToSumString can't identify the following parameter: " num "`n"
    return num
}

logWeirdTimingCase(dashZoneHist, dashTimestampNow, out) {
    logAppend("pivotTimingCheck([{t: " numToSumStr(dashZoneHist[1].timestamp) "}"
    . ", {t: " numToSumStr(dashZoneHist[2].timestamp) ", zone: " (dashZoneHist[2].zone ? "true" : "false") "}"
    . ", {t: " numToSumStr(dashZoneHist[3].timestamp) "}]" 
    . ", " numToSumStr(dashTimestampNow) ") yields " out)
}


; time checks
timeHist := [{timestamp: 0}, {zone: false, timestamp: 0}, {timestamp: 0}]

TIMESTALE_PIVOT_INPUTSEQUENCE := 1000
TIMELIMIT_FRAME := 200
ONE_FRAME := 200
TIMELIMIT_HALFFRAME := 100

timeHist[2].timestamp := timeHist[3].timestamp
timeHist[1].timestamp := timeHist[2].timestamp
; accept, edge timing
dashTimestampNow := timeHist[1].timestamp + TIMELIMIT_HALFFRAME
out := pivotTimingCheck(timeHist, dashTimestampNow)
if !out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}
; deny, bad timing
dashTimestampNow := timeHist[1].timestamp + TIMELIMIT_HALFFRAME - 1
out := pivotTimingCheck(timeHist, dashTimestampNow)
if out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}

; accept, edge timing
dashTimestampNow := timeHist[1].timestamp + TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME
out := pivotTimingCheck(timeHist, dashTimestampNow)
if !out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}
; deny, bad timing
dashTimestampNow := timeHist[1].timestamp + TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME + 1
out := pivotTimingCheck(timeHist, dashTimestampNow)
if out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}

; accept, edge nonstaleness
; the following sequence should trip:  NOW center  1 oppositeCardinal  2 cardinal
timeHist[2].zone := true
;                        timeHist[3] will be stale
timeHist[2].timestamp := timeHist[3].timestamp + 1
;                        timeHist[2] will be only almost stale
timeHist[1].timestamp := timeHist[2].timestamp + TIMESTALE_PIVOT_INPUTSEQUENCE - ONE_FRAME
dashTimestampNow := timeHist[1].timestamp + ONE_FRAME ; good timing
out := pivotTimingCheck(timeHist, dashTimestampNow)
if !out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}
; deny, stale dashZoneHist
; the following sequence is stale:  NOW center  1 oppositeCardinal  2 cardinal
timeHist[2].zone := true
timeHist[2].timestamp := timeHist[3].timestamp
;                        timeHist[2] will be stale
timeHist[1].timestamp := timeHist[2].timestamp + (TIMESTALE_PIVOT_INPUTSEQUENCE + 1) - ONE_FRAME
dashTimestampNow := timeHist[1].timestamp + ONE_FRAME ; good timing
out := pivotTimingCheck(timeHist, dashTimestampNow)
if out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}

; accept, edge nonstaleness
; for the following sequence:  NOW center  1 oppositeCardinal  2 center  3 cardinal
timeHist[2].zone := false
;                        timeHist[3] will be only almost stale
timeHist[2].timestamp := timeHist[3].timestamp + TIMESTALE_PIVOT_INPUTSEQUENCE - ONE_FRAME 
timeHist[1].timestamp := timeHist[2].timestamp 
dashTimestampNow := timeHist[1].timestamp + ONE_FRAME ; good timing
out := pivotTimingCheck(timeHist, dashTimestampNow)
if !out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}
; deny, stale dashZoneHist
; the following sequence is stale:  NOW center  1 oppositeCardinal  2 center  3 cardinal
timeHist[2].zone := false
;                        timeHist[3] will be stale
timeHist[2].timestamp := timeHist[3].timestamp + (TIMESTALE_PIVOT_INPUTSEQUENCE + 1) - ONE_FRAME 
timeHist[1].timestamp := timeHist[2].timestamp
dashTimestampNow := timeHist[1].timestamp + ONE_FRAME ; good timing
out := pivotTimingCheck(timeHist, dashTimestampNow)
if out {
    logWeirdTimingCase(timeHist, dashTimestampNow, out)
}


logAppend("pivotDetection finish`n")