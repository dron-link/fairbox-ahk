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

logAppend("slowTargeting")
logAppend(A_LineFile "`n")

TIMELIMIT_SIMULTANEOUS := 4 ; smallest quantity after the millisecond...
                            ; we should be sure at all times of its value

currentTimeMS := 0
getOutputLimited(0, 0)

;slow targeting
Loop, 10 {
    slowTargetingFail := false ; fail flag

    currentTimeMS += 1000
    Random, x, -90, 90
    Random, y, -90, 90
    coords := trimToCircle([x, y])
    x := coords[xComp], y := coords[yComp]
    out := getOutputLimited(x, y)
    if (Abs(out.x - x) > 1 or Abs(out.y - y) > 1) { ; are the output components NOT within 1 unit of the target?
        slowTargetingFail := true
    }

    ; attempt to return to center
    currentTimeMS += 1000
    out0 := getOutputLimited(0, 0)
    if (out0.x or out0.y or slowTargetingFail) {
        logAppend("slow targeting fail. " 
        . "x " x " out.x " out.x ", y " y " out.y " out.y ", return to [0, 0] out.x " out0.x " out.y " out0.y)
    }
}

logAppend("slowTargeting finish`n")