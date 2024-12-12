#Requires AutoHotkey v1

trimToOctagonGate(coords) {
    global xComp, global yComp
    aX := coords[xComp], aY := coords[yComp]
    coordsRadius := Sqrt(aX**2 + aY**2)
    if (coordsRadius > getGateRadius(Abs(aX), Abs(aY))) {
        return bringToOctagonGate(coords)
    }
    return coords ; if conditions weren't met, we return the same value
}