#Requires AutoHotkey v1
#Warn All, MsgBox

#Include %A_WorkingDir%\source\coordinates\bringToCircleBorder.ahk
#Include %A_WorkingDir%\source\coordinates\trimToCircle.ahk
#Include %A_WorkingDir%\source\system\fairboxConstants.ahk
#Include %A_WorkingDir%\source\system\gameEngineConstants.ahk

#Include %A_WorkingDir%\logAppend.ahk

logAppend("testTrimToCircle")
logAppend(A_LineFile "`n")

x := -128
Loop {
    y := -128
    Loop {
        trimmedCoords := trimToCircle([x, y])
        trimX := trimmedCoords[xComp], trimY := trimmedCoords[yComp]
        ; below or same as max diameter. output should be same as input
        if (x**2 + y**2 <= ANALOG_STICK_MAX**2) {
            if !(x == trimX and y == trimY) {
                logAppend("unnecesary alteration (coordinate already below or same as max diameter). "
                . "x " x " y " y " trimX " trimX " trimY " trimY)
            }
        }
        ; over max diameter, must be trimmed
        else { ; if (x**2 + y**2 > ANALOG_STICK_MAX**2)
            if (x == trimX and y == trimY) {
                logAppend("Input over max diameter unaltered. "
                . "x " x " y " y " trimX " trimX " trimY " trimY)
            }
            ; if trimmed coords' radius go beyond the unit circle
            else if (trimX**2 + trimY**2 > ANALOG_STICK_MAX**2) {
                logAppend("OVERshoot. "
                . "x " x " y " y " trimX " trimX " trimY " trimY)
            }
            /*  if trimmed coordinates' radius falls below the radius of [59, 52] which is the
                border's coordinate that is closest to center (reflections and rotations too).
                source: CarVac, dronlink
            */
            else if (trimX**2 + trimY**2 < 59**2 + 52**2) {
                logAppend("undershoot. "
                . "x " x " y " y " trimX " trimX " trimY " trimY)
            }
        }
        y += 1
    } Until y > 128
    x += 1
} Until x > 128

logAppend("testTrimToCircle finish`n")

return