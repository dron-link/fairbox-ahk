#Requires AutoHotkey v1.1

trimToCircle(coords) {
    /*  the game considers coordinates outside the circle as coordinates on the rim of the circle,
        (preserving the original angle). rest of this program isn't suited to handle coordinates out of
        circle though
    */
    global ANALOG_STICK_MAX, global xComp, global yComp
    aX := coords[xComp], aY := coords[yComp]
    if (aX**2 + aY**2 > ANALOG_STICK_MAX**2) {
        return bringToCircleBorder(coords)
    }
    
    return coords ; if conditions weren't met, we return the same value
}
