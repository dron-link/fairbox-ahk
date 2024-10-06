#Requires AutoHotkey v1.1

if !allowTrimming {
    OutputDebug, % "allowTrimming is false. Turn to true when you finish testing`n"
}

trimToCircle(aX, aY) { ; the game considers coordinates outside the circle as coordinates on the rim of the circle,
                       ; preserving the angle. rest of this program isn't suited to handle coordinates out of
                       ; circle though
    global target
    global ANALOG_STICK_MAX
    global allowTrimming
    result := [aX, aY]
    if (aX != 0 or aY != 0) {
        squaredRadius := aX**2 + aY**2
        if (squaredRadius > ANALOG_STICK_MAX**2 and allowTrimming) {
            if (aX > 0) {
                result[1] := Floor(80 * aX / Sqrt(squaredRadius))
            } else { ; if aX < 0
                result[1] := Ceil(80 * aX / Sqrt(squaredRadius))
            }
            if (aY > 0) {
                result[2] := Floor(80 * aY / Sqrt(squaredRadius))
            } else { ; if aY < 0
                result[2] := Ceil(80 * aY / Sqrt(squaredRadius))
            }
        } else {
            result[1] := Round(result[1])
            result[2] := Round(result[2])
        }
    }

    /* ; force convert into integer 
    result[1] := Format("{:d}", result[1])
    result[2] := Format("{:d}", result[2])
    */
    return result
}

detectNonIntegers(aX, aY) {
    if aX is not Integer
        OutputDebug, detectNonIntegers() problem . coordinate x type is not integer`n
    if aY is not Integer
        OutputDebug, detectNonIntegers() problem . coordinate y type is not integer`n
    return
}  

/* ; trimToCircle(x, y) test utility
Loop, 256 {
    testX := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
    Loop, 256 {
        testY := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
        testCoordinates := trimToCircle(testX, testY)
        if (testCoordinates[1] != testX or testCoordinates[2] != testY) {
            if (testCoordinates[1]**2 + testCoordinates[2]**2 > ANALOG_STICK_MAX**2) {
                OutputDebug, % "trimToCircle overshoot " 
                . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
            }
            if (testCoordinates[1]**2 + testCoordinates[2]**2 <= 56**2 + 55**2) {
                OutputDebug, % "trimToCircle undershoot " 
                . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
            }
        } else if (testCoordinates[1]**2 + testCoordinates[2]**2 > ANALOG_STICK_MAX**2) {
            OutputDebug, % "trimToCircle ignored or didn't change coord out of circle " 
            . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
        }
        
    }
}
OutputDebug, % "trimToCircle test concluded"
*/


countCoordinatesOutsideUnit := 0
for context in target {
    if (context = "format") {
        Continue
    }
    for keyName, specificCoordinate in target[context] {
        ; if this never evaluates to true, it's likely that the coordinates are in unit circle format 
        if (specificCoordinate[1] >= 3 or specificCoordinate[2] >= 3) {
            countCoordinatesOutsideUnit += 1
        }

        if target.format.unitCircle {
            ; converts from [-1, 1] to [-80, 80]
            specificCoordinate[1] *= UNITCIRC_TO_INT
            specificCoordinate[2] *= UNITCIRC_TO_INT
        } else if target.format.centerOffsetBy128 {
            ; converts from [48, 208] to [-80, 80]
            specificCoordinate[1] += ANALOG_STICK_OFFSETCANCEL
            specificCoordinate[2] += ANALOG_STICK_OFFSETCANCEL
        }
        ; converts to integer, trims values outside the analog coordinate circle
        specificCoordinate[1] := Round(specificCoordinate[1])
        specificCoordinate[2] := Round(specificCoordinate[2])
        trimmedCoordinate := trimToCircle(specificCoordinate[1], specificCoordinate[2])
        if (trimmedCoordinate[1] != specificCoordinate [1] or trimmedCoordinate[2] != specificCoordinate [2]) {
            if target.format.unitCircle {
                debugPrintX := specificCoordinate[1] * INT_TO_UNITCIRC
                debugPrintY := specificCoordinate[2] * INT_TO_UNITCIRC
                debugPrintExcessMagnitude := (Sqrt(specificCoordinate[1]**2 + specificCoordinate[2]**2)
                - ANALOG_STICK_MAX) * INT_TO_UNITCIRC
                OutputDebug, % "x " Format("{:.4f}", debugPrintX) " y " Format("{:.4f}", debugPrintY) 
            } else if target.format.centerOffsetBy128 {
                debugPrintExcessMagnitude := Sqrt(specificCoordinate[1]**2 + specificCoordinate[2]**2) 
                - ANALOG_STICK_MAX
                OutputDebug, % "x " specificCoordinate[1] - ANALOG_STICK_OFFSETCANCEL
                . " y " specificCoordinate[2] - ANALOG_STICK_OFFSETCANCEL
            } else {
                debugPrintExcessMagnitude := Sqrt(specificCoordinate[1]**2 + specificCoordinate[2]**2)
                - ANALOG_STICK_MAX
                OutputDebug, % "x " specificCoordinate[1] . " y " specificCoordinate[2] 
            }

            OutputDebug, % " excess_magnitude " Format("{:.4f}", debugPrintExcessMagnitude)
            . ". Clamped to circle`n"
        }
        specificCoordinate[1] := trimmedCoordinate[1]
        specificCoordinate[2] := trimmedCoordinate[2]
        detectNonIntegers(specificCoordinate[1], specificCoordinate[2])
        
    }
}
suggestedUnitCircleMode := ""
if (!target.format.unitCircle and countCoordinatesOutsideUnit < 1) {
    suggestedUnitCircleMode := "TRUE"
} else if (target.format.unitCircle and countCoordinatesOutsideUnit >= 9) {
    suggestedUnitCircleMode := "FALSE"
}
if (suggestedUnitCircleMode != "") {
    OutputDebug, % "Alert. It was detected that target.format.unitCircle likely needs to be edited to "
    . suggestedUnitCircleMode
    . " inside the file targetCoordinateValues.ahk ! `n"
    . "^ countCoordinatesOutsideUnit evaluates to " countCoordinatesOutsideUnit "`n"
    MsgBox % "Alert. It was detected that target.format.unitCircle likely needs to be edited to "
    . suggestedUnitCircleMode
    . " inside the file targetCoordinateValues.ahk !"
}