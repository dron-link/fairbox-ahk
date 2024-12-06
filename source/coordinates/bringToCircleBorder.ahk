#Requires AutoHotkey v1.1

bringToCircleBorder(coords) {
    global ANALOG_STICK_MAX, global xComp, global yComp
    aX := coords[xComp], aY := coords[yComp]
    if (aX != 0 or aY != 0) { ; Sqrt(squaredRadius) > 0 avoids division by zero
        squaredRadius := aX**2 + aY**2
        circleCoords := []
        if (aX < 0) {
            circleCoords[xComp] := Ceil(ANALOG_STICK_MAX * aX / Sqrt(squaredRadius))
        } else { ; if aX >= 0
            circleCoords[xComp] := Floor(ANALOG_STICK_MAX * aX / Sqrt(squaredRadius))
        }
        if (aY < 0) {
            circleCoords[yComp] := Ceil(ANALOG_STICK_MAX * aY / Sqrt(squaredRadius))
        } else { ; if aY >= 0
            circleCoords[yComp] := Floor(ANALOG_STICK_MAX * aY / Sqrt(squaredRadius))
        }
        return circleCoords
    }
    return coords ; if conditions weren't met, we return the same value
}