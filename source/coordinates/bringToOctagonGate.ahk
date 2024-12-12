#Requires AutoHotkey v1

bringToOctagonGate(coords) {
    global xComp, global yComp
    aX := coords[xComp], aY := coords[yComp]
    if (aX != 0 or aY != 0) { ; avoid division by zero
        coordsRadius := Sqrt(aX**2 + aY**2)
        gateRadius := getGateRadius(Abs(aX), Abs(aY))

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

getGateRadius(absX, absY) {
    global GATE_MAX_RADIUS
    if (!absX and !absY) { 
        return 0 ; avoid division by zero
    }
    return  GATE_MAX_RADIUS * Sqrt(aX**2 + aY**2) 
        / (absX > absY ? absX + (Sqrt(2) - 1) * absY : (Sqrt(2) - 1) * absX + absY)
}