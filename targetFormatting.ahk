#Requires AutoHotkey v1.1

trimToCircle(aX, aY) {
    global target
    result := [aX, aY]
    if (aX != 0 or aY != 0) {
        magnitudeRelativeToRim := Sqrt(aX**2 + aY**2) / 80
        if (magnitudeRelativeToRim > 1) {
            if (aX >= 0) {
                result[1] := Floor(aX / magnitudeRelativeToRim)
            } else { ; if aX < 0
                result[1] := Ceil(aX / magnitudeRelativeToRim)
            }
            if (aY >= 0) {
                result[2] := Floor(aY / magnitudeRelativeToRim)
            } else { ; if aY < 0
                result[2] := Ceil(aY / magnitudeRelativeToRim)
            }
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
countCoordinatesOutsideUnit := 0
for context in target {
    if (context = "unitCircleMode" or context = "centerOffsetBy128") {
        Continue
    }
    for keyName, specificCoordinate in target[context] {
        ; if this never evaluates to true, it's likely that the coordinates are in unit circle format 
        if (specificCoordinate[1] >= 3 or specificCoordinate[2] >= 3) {
            countCoordinatesOutsideUnit += 1
        }

        if target.unitCircleMode {
            ; converts from [-1, 1] to [-80, 80]
            specificCoordinate[1] *= 80
            specificCoordinate[2] *= 80
        } else if target.centerOffsetBy128 {
            ; converts from [48, 208] to [-80, 80]
            specificCoordinate[1] += ANALOG_STICK_OFFSETCANCEL
            specificCoordinate[2] += ANALOG_STICK_OFFSETCANCEL
        }
        ; converts to integer, trims values outside the analog coordinate circle
        specificCoordinate[1] := Round(specificCoordinate[1])
        specificCoordinate[2] := Round(specificCoordinate[2])
        trimmedCoordinate := trimToCircle(specificCoordinate[1], specificCoordinate[2])
        if (trimmedCoordinate[1] != specificCoordinate [1] or trimmedCoordinate[2] != specificCoordinate [2]) {
            if target.unitCircleMode {
                debugPrintX := specificCoordinate[1]/80
                debugPrintY := specificCoordinate[2]/80
                debugPrintExcessMagnitude := Sqrt(specificCoordinate[1]**2 + specificCoordinate[2]**2)/80 - 1
                OutputDebug, % "x " Format("{:.4f}", debugPrintX) " y " Format("{:.4f}", debugPrintY) 
            } else if target.centerOffsetBy128 {
                debugPrintExcessMagnitude := Sqrt(specificCoordinate[1]**2 + specificCoordinate[2]**2) - 80
                OutputDebug, % "x " specificCoordinate[1] - ANALOG_STICK_OFFSETCANCEL
                . " y " specificCoordinate[2] - ANALOG_STICK_OFFSETCANCEL
            } else {
                debugPrintExcessMagnitude := Sqrt(specificCoordinate[1]**2 + specificCoordinate[2]**2) - 80
                OutputDebug, % "x " specificCoordinate[1] . " y " specificCoordinate[2] 
            }

            OutputDebug, % " excess_magnitude " Format("{:.4f}", debugPrintExcessMagnitude)
            . ". Clamped to circle`n"
        }
        specificCoordinate := trimmedCoordinate
        detectNonIntegers(specificCoordinate[1], specificCoordinate[2])
        
    }
}
suggestedUnitCircleMode := ""
if (!target.unitCircleMode and countCoordinatesOutsideUnit < 1) {
    suggestedUnitCircleMode := "TRUE"
} else if (target.unitCircleMode and countCoordinatesOutsideUnit >= 9) {
    suggestedUnitCircleMode := "FALSE"
}
if (suggestedUnitCircleMode != "") {
    OutputDebug, % "Alert. It was detected that target.unitCircleMode likely needs to be edited to "
    . suggestedUnitCircleMode
    . " inside the file targetCoordinateValues.ahk ! `n"
    . "^ countCoordinatesOutsideUnit evaluates to " countCoordinatesOutsideUnit "`n"
    MsgBox % "Alert. It was detected that target.unitCircleMode likely needs to be edited to "
    . suggestedUnitCircleMode
    . " inside the file targetCoordinateValues.ahk !"
}