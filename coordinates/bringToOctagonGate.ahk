#Requires AutoHotkey v1.1

bringToOctagonGate(coords) {
    global xComp, global yComp
    aX := coords[xComp], aY := coords[yComp]
    if (aX != 0 or aY != 0) { ; avoid division by zero
        coordsRadius := Sqrt(aX**2 + aY**2)
        gateRadius := getGateRadius(aX, aY, coordsRadius)

        octagonCoords := []
        if (aX < 0) {
            octagonCoords[xComp] := Ceil(gateRadius * aX / coordsRadius)
        } else { ; if aX >= 0
            octagonCoords[xComp] := Floor(gateRadius * aX / coordsRadius)
        }
        if (aY < 0) {
            octagonCoords[yComp] := Ceil(gateRadius * aY / coordsRadius)
        } else { ; if aY >= 0
            octagonCoords[yComp] := Floor(gateRadius * aY / coordsRadius)
        }
        return octagonCoords
    }
    return coords
}

getGateRadius(aX, aY, coordsRadius) {
    global GATE_MAX_RADIUS
    if (!aX and !aY) { 
        return 0 ; avoid division by zero
    }
    return coordsRadius * GATE_MAX_RADIUS 
        / (Abs(aX) > Abs(aY) ? Abs(aX) + (Sqrt(2) - 1) * Abs(aY) : (Sqrt(2) - 1) * Abs(aX) + Abs(aY))
}