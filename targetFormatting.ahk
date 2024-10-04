#Requires AutoHotkey v1.1

trimToCircle(aX, aY) {
    result := [aX, aY]
    if (aX != 0 or aY != 0) {
        clampFactor := 80 / Sqrt(aX**2 + aY**2)
        if (clampFactor < 1) {
            if (aX >= 0) {
                result[1] := Floor(aX * clampFactor)
            } else { ; if aX < 0
                result[1] := Ceil(aX * clampFactor)
            }
            if (aY >= 0) {
                result[2] := Floor(aY * clampFactor)
            } else { ; if aY < 0
                result[2] := Ceil(aY * clampFactor)
            }
        }
    }
    /* ; converts to integer type 
        result[1] := Format("{:d}", % result[1])
        result[2] := Format("{:d}", % result[2])
    */
    if result[1] is not integer 
        OutputDebug, problem in targetFormatting.ahk/trimToCircle() . result type is not integer
    if result[2] is not integer 
        OutputDebug, problem in targetFormatting.ahk/trimToCircle() . result type is not integer
    return result
} ; end of function

; converts from [-1, 1] to [-80, 80]
if modeIsUnitCircle {
    for index, element in target.normal {
        element[1] := 80 * element[1]
        element[2] := 80 * element[2]
    }
    for index, element in target.airdodge {
        element[1] := 80 * element[1]
        element[2] := 80 * element[2]
    }
    for index, element in target.fireFox {
        element[1] := 80 * element[1]
        element[2] := 80 * element[2]
    }
    for index, element in target.extendedB {
        element[1] := 80 * element[1]
        element[2] := 80 * element[2]
    }
; converts from [22, 208] to [-80, 80]
} else if circleNeutralOffset {
    for index, element in target.normal {
        element[1] -= 128
        element[2] -= 128
    }
    for index, element in target.airdodge {
        element[1] -= 128
        element[2] -= 128
    }
    for index, element in target.fireFox {
        element[1] -= 128
        element[2] -= 128
    }
    for index, element in target.extendedB {
        element[1] -= 128
        element[2] -= 128
    }
}

; trims value to circle
for index, element in target.normal {
    element[1] := Round(element[1])
    element[2] := Round(element[2])
    element := trimToCircle(element[1], element[2])
}
for index, element in target.airdodge {
    element[1] := Round(element[1])
    element[2] := Round(element[2])
    element := trimToCircle(element[1], element[2])
}
for index, element in target.fireFox {
    element[1] := Round(element[1])
    element[2] := Round(element[2])
    element := trimToCircle(element[1], element[2])
}
for index, element in target.extendedB {
    element[1] := Round(element[1])
    element[2] := Round(element[2])
    element := trimToCircle(element[1], element[2])
}

/*
for index, element in target.normal {

}
for index, element in target.airdodge {

}
for index, element in target.fireFox {

}
for index, element in target.extendedB {

}
*/