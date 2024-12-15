#Requires AutoHotkey v1
#Warn All, MsgBox

#Include %A_WorkingDir%\source\coordinates\bringToCircleBorder.ahk
#Include %A_WorkingDir%\source\system\fairboxConstants.ahk
#Include %A_WorkingDir%\source\system\gameEngineConstants.ahk

#Include %A_WorkingDir%\logAppend.ahk

logAppend("testBringToCircleBorder")
logAppend(A_LineFile "`n")

/*  [59, 52] is the border's coordinate that is closest to center (along with its reflections and rotations).
    source: CarVac, dronlink
*/
BORDER_MIN_SQUARED := 59**2 + 52**2

x := -128
Loop {
    y := -128
    Loop {
        borderCoords := bringToCircleBorder([x, y])
        borderX := borderCoords[xComp], borderY := borderCoords[yComp]

        if (x == borderX and y == borderY) {
            if (x == 0 and y == 0) {
                ; special case
            }
            else if (ANALOG_STICK_MAX**2 < x**2 + y**2) { ; input outside border
                logAppend("input outside the border unaltered. "
                . "x " x " y " y " borderX " borderX " borderY " borderY)
            }

            else if (x**2 + y**2 < BORDER_MIN_SQUARED) { ; input within the inner side of the border
                logAppend("input too close to center unaltered. "
                . "x " x " y " y " borderX " borderX " borderY " borderY)
            }
        }

        ; if trimmed or pushed coords' radius go beyond the unit circle
        else if (borderX**2 + borderY**2 > ANALOG_STICK_MAX**2) {
            logAppend("OVERshoot. "
                . "x " x " y " y " borderX " borderX " borderY " borderY)
        }
        /*  if trimmed or pushed coordinates' distance falls below the distance of [59, 52]
        */
        else if (borderX**2 + borderY**2 < BORDER_MIN_SQUARED) {
            logAppend("undershoot. "
                . "x " x " y " y " borderX " borderX " borderY " borderY)
        }

        y += 1
    } Until y > 128
    x += 1
} Until x > 128

logAppend("testBringToCircleBorder finish`n")