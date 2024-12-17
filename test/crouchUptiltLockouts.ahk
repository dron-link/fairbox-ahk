#Requires AutoHotkey v1

#Include %A_WorkingDir%\source\analogZoneInfo\analogZoneInfo.ahk
#Include %A_WorkingDir%\source\coordinates\bringToCircleBorder.ahk
#Include %A_WorkingDir%\source\coordinates\trimToCircle.ahk
#Include %A_WorkingDir%\source\limitOutputs\limitOutputs.ahk
#Include %A_WorkingDir%\source\system\fairboxConstants.ahk
#Include %A_WorkingDir%\source\system\gameEngineConstants.ahk
#Include %A_WorkingDir%\source\system\hotkeys.ahk
#Include %A_WorkingDir%\source\technique\technique.ahk

#Include %A_WorkingDir%\logAppend.ahk

logAppend("crouchUptiltLockouts")
logAppend(A_LineFile "`n")

TIMELIMIT_SIMULTANEOUS := 4 ; smallest quantity after the millisecond...
; we should be sure at all times of its value

logExpect(out, expected, title) {
    global xComp, global yComp
    if (out.x != expected[xComp] or out.y != expected[yComp]) {
        logAppend(title ": unexpected output. "
            . "[" expected[xComp] ", " expected[yComp] "] => out.x " out.x " out.y " out.y)
    }
}

currentTimeMS := 0

getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

getOutputLimited(0, -80) ; crouch
currentTimeMS += TIMELIMIT_SIMULTANEOUS

; place the analog stick in all regions except upY centerX
logExpect(getOutputLimited(0, 0), [0, 0], "uncrouch. no nerf")
logExpect(getOutputLimited(-25, 25), [-25, 25], "uncrouch. no nerf")
logExpect(getOutputLimited(-25, 0), [-25, 0], "uncrouch. no nerf")
logExpect(getOutputLimited(-25, -25), [-25, -25], "uncrouch. no nerf")
logExpect(getOutputLimited(0, -25), [0, -25], "uncrouch. no nerf")
logExpect(getOutputLimited(25, -25), [25, -25], "uncrouch. no nerf")
logExpect(getOutputLimited(25, 0), [25, 0], "uncrouch. no nerf")
logExpect(getOutputLimited(25, 25), [25, 25], "uncrouch. no nerf")

; nerf
logExpect(getOutputLimited(0, 25), getUncrouchNerfedCoords()
, "uncrouch. insta uptilt --> force tapjump")
logExpect(getOutputLimited(0, 75), getUncrouchNerfedCoords()
, "uncrouch. insta tapjump --> force tapjump")
logExpect(getOutputLimited(0, 80), getUncrouchNerfedCoords()
, "uncrouch. insta full cardinal up --> force tapjump")

; lockout expiration (slow version)
currentTimeMS += 1000
logExpect(getOutputLimited(0, 25), [0, 25]
, "uncrouch. uptilt --> force tapjump")

/*


*/

; timing edge cases

getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

getOutputLimited(0, -80) ; crouch
currentTimeMS += TIMELIMIT_SIMULTANEOUS

getOutputLimited(0, 0)
currentTimeMS += TIMELIMIT_DOWNUP -1

logExpect(getOutputLimited(0, 25), getUncrouchNerfedCoords(), "uncrouch. uptilt lockout timing edge case")

currentTimeMS += 1 + 0.000001
logExpect(getOutputLimited(0, 25), [0, 25], "uncrouch. uptilt lockout expiration edge case")

; test crouching twice in a row
getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

getOutputLimited(0, -80) ; crouch
currentTimeMS += TIMELIMIT_SIMULTANEOUS

getOutputLimited(0, 0) ; uncrouch
; arbitrary amount of time that is less than the time needed to time out the lockout
currentTimeMS += TIMELIMIT_DOWNUP / 3 

getOutputLimited(0, -80) ; crouch
currentTimeMS += TIMELIMIT_SIMULTANEOUS

getOutputLimited(0, 0) ; uncrouch
currentTimeMS += TIMELIMIT_DOWNUP -1

logExpect(getOutputLimited(0, 25), getUncrouchNerfedCoords(), "uncrouch (twice). uptilt lockout timing edge case ")

currentTimeMS += 1 + 0.000001
logExpect(getOutputLimited(0, 25), [0, 25], "uncrouch (twice). uptilt lockout expiration edge case")

logAppend("crouchUptiltLockouts finish`n")

Return

uncrouchNerfLiftTimerLabel:
return

pivotYDashNerfLiftTimerLabel:
return

pivotNerfLiftTimerLabel:
return