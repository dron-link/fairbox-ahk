#Requires AutoHotkey v1.1

formatTargetCoordinates(ByRef target) {
    global UNITCIRC_TO_INT
    global ANALOG_STICK_OFFSETCANCEL
    global INT_TO_UNITCIRC
    global xComp, global yComp

    ; format each specific coordinate into integer 0-centered format
    countCoordinatesOutsideUnitCircle := 0
    for context in target {
        if (context = "format") { ; target.format doesn't store coordinates
            Continue
        }
        for keyName, specificCoords in target[context] { ; such as target.fireFox, target.airdodge, etc

            /*  the idea is that if countCoordinatesOutsideUnitCircle ends as 0, it's likely that the
                coordinates are in unit circle format, and, if many coordinates are outside
                the unit circle then it's likely that the coordinates are in integer format
            */
            ; 2 is double the unit circle radius: it is even more lenient than using 128/80 = 1.6
            ; also take into account that most of the time these will be quadrant I coordinates
            if (specificCoords[xComp] >= 2 or specificCoords[yComp] >= 2) { 
                countCoordinatesOutsideUnitCircle += 1
            }

            if target.format.unitCircle { ; note: overrides target.format.centerOffsetBy128
                ; converts from [-1, 1] to [-80, 80]
                specificCoords[xComp] *= UNITCIRC_TO_INT
                specificCoords[yComp] *= UNITCIRC_TO_INT
            } else if target.format.centerOffsetBy128 {
                ; converts from [48, 208] to [-80, 80]
                specificCoords[xComp] += ANALOG_STICK_OFFSETCANCEL
                specificCoords[yComp] += ANALOG_STICK_OFFSETCANCEL
            }
            ; converts to integer type, trims values outside the analog coordinate circle
            specificCoords[xComp] := Round(specificCoords[xComp])
            specificCoords[yComp] := Round(specificCoords[yComp])
        }
    }
    
    suggestedUnitCircleMode := ""
    ; if unitCircle but the only coordinates close to the unit circle are [0, 0]
    if (!target.format.unitCircle and countCoordinatesOutsideUnitCircle < 1) {
        suggestedUnitCircleMode := "TRUE"
    }
    ; if unitCircle but there are at least 9 coordinates that go far beyond the unit circle
    else if (target.format.unitCircle and countCoordinatesOutsideUnitCircle >= 9) {
        suggestedUnitCircleMode := "FALSE"
    }

    if (suggestedUnitCircleMode != "") {
        warningMsg := "Warning. It was detected that target.format.unitCircle likely needs to be edited to "
            . suggestedUnitCircleMode
            . " inside the source file " A_ScriptDir "\source\coordinates\target\loadCoordinateValues.ahk !"
        OutputDebug, % warningMsg 
        . "`nvar countCoordinatesOutsideUnitCircle evaluates to " countCoordinatesOutsideUnitCircle "`n"
        MsgBox % warningMsg
    }
    return
}
