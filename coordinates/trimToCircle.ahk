#Requires AutoHotkey v1.1

trimToCircle(coords) {
    /*  the game considers coordinates outside the circle as coordinates on the rim of the circle,
        (preserving the original angle). rest of this program isn't suited to handle coordinates out of
        circle though
    */
    global ANALOG_STICK_MAX, global xComp, global yComp
    aX := coords[xComp], aY := coords[yComp]
    if (aX != 0 or aY != 0) { ; sqrt(squaredRadius) > 0 avoids division by zero
        squaredRadius := aX**2 + aY**2
        if (squaredRadius > ANALOG_STICK_MAX**2) {
            trimmedCoords := []
            if (aX > 0) {
                trimmedCoords[xComp] := Floor(80 * aX / Sqrt(squaredRadius))
            } else { ; if aX <= 0
                trimmedCoords[xComp] := Ceil(80 * aX / Sqrt(squaredRadius))
            }
            if (aY > 0) {
                trimmedCoords[yComp] := Floor(80 * aY / Sqrt(squaredRadius))
            } else { ; if aY <= 0
                trimmedCoords[yComp] := Ceil(80 * aY / Sqrt(squaredRadius))
            }
            return trimmedCoords
        }
    }

    return coords ; if conditions weren't met, we return the same value
}
