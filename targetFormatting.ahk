#Requires AutoHotkey v1.1

trimToCircle(aX, aY) { 
    /*  the game considers coordinates outside the circle as coordinates on the rim of the circle,
        (preserving the original angle). rest of this program isn't suited to handle coordinates out of
        circle though
    */
    global target
    global ANALOG_STICK_MAX
    result := [aX, aY]
    if (aX != 0 or aY != 0) {
        squaredRadius := aX**2 + aY**2
        if (squaredRadius > ANALOG_STICK_MAX**2) {
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
        }
    }

    /* ; force convert into integer 
    result[1] := Format("{:d}", result[1])
    result[2] := Format("{:d}", result[2])
    */
    return result
}


countCoordinatesOutsideUnit := 0
for context in target {
    if (context = "format") { ; target.format doesn't contain coordinates in itself
        Continue
    }
    for keyName, specificCoordinate in target[context] { ; such as target.fireFox, target.airdodge, etc

        /* 
        if countCoordinatesOutsideUnit(circle) ends as 0, it's likely that the 
        coordinates are in unit circle format, and, if many coordinates are outside 
        the unit circle then it's likely that the coordinates are in integer format
        */ 
        if (specificCoordinate[1] >= 2 or specificCoordinate[2] >= 2) {
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

        ; start of trimmed-values alert
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
        } ; end of trimmed-values alert

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
    warningMsg := "Warning. It was detected that target.format.unitCircle likely needs to be edited to "
    . suggestedUnitCircleMode
    . " inside the file targetCoordinateValues.ahk ! `n"
    OutputDebug, % warningMsg "var countCoordinatesOutsideUnit evaluates to " countCoordinatesOutsideUnit "`n"
    MsgBox % warningMsg
}