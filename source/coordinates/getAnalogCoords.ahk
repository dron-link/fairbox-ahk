#Requires AutoHotkey v1.1

getAnalogCoords() {
    global buttonB
    if anyShield() {
        quadrantIMirrorCoords := getAnalogCoordsAirdodge()
    } else if (anyMod() and anyQuadrant() and (anyC() or buttonB)) {
        quadrantIMirrorCoords := getAnalogCoordsFirefox()
    } else {
        quadrantIMirrorCoords := getAnalogCoordsWithNoShield()
    }

    return reflectCoords(quadrantIMirrorCoords)
}

reflectCoords(quadrantIMirrorCoords) {
    global xComp, global yComp
    x := quadrantIMirrorCoords[xComp], y := quadrantIMirrorCoords[yComp]
    if (down()) {
        y *= -1
    }
    if (left()) {
        x *= -1
    }
    return [x, y]
}

getAnalogCoordsWithNoShield() {
    global
    if (!anyVert() and !anyHoriz()) {
        lastCoordTrace := "N-O"
        return new target.normal.origin
    } else if (anyQuadrant()) {
        if (modX()) {
            lastCoordTrace := "N-Q-X"
            return new target.normal.quadrantModX
        } else if (modY()) {
            lastCoordTrace := "N-Q-Y"
            return new target.normal.quadrantModY
        } else {
            lastCoordTrace := "N-Q"
            return new target.normal.quadrant
        }
    } else if (anyVert()) {
        if (modX()) {
            lastCoordTrace := "N-V-X"
            return new target.normal.verticalModX
        } else if (modY()) {
            lastCoordTrace := "N-V-Y"
            return new target.normal.verticalModY
        } else {
            lastCoordTrace := "N-V"
            return new target.normal.vertical
        }
    } else { ; if (anyHoriz())
        if (modX()) {
            lastCoordTrace := "N-H-X"
            return new target.normal.horizontalModX
        } else if (modY()) {
            lastCoordTrace := "N-H-Y"
            return new target.normal.horizontalModY
        } else {
            lastCoordTrace := "N-H"
            return new target.normal.horizontal
        }
    }
}

getAnalogCoordsAirdodge() {
    global
    if (!anyVert() and !anyHoriz()) {
        lastCoordTrace := "L-O"
        return new target.normal.origin
    } else if (anyQuadrant()) {
        if (modX()) {
            lastCoordTrace := "L-Q-X"
            return new target.airdodge.quadrantModX
        } else if (modY()) {
            lastCoordTrace := "L-Q-Y"
            return up() ? new target.airdodge.quadrant12ModY : new target.airdodge.quadrant34ModY
        } else {
            lastCoordTrace := "L-Q"
            return up() ? new target.airdodge.quadrant12 : new target.airdodge.quadrant34
        }
    } else if (anyVert()) {
        if (modX()) {
            lastCoordTrace := "L-V-X"
            return new target.airdodge.verticalModX
        } else if (modY()) {
            lastCoordTrace := "L-V-Y"
            return new target.airdodge.verticalModY
        } else {
            lastCoordTrace := "L-V"
            return new target.airdodge.vertical
        }
    } else { ; if (anyHoriz())
        if (modX()) {
            lastCoordTrace := "L-H-X"
            return new target.airdodge.horizontalModX
        } else if (modY()) {
            lastCoordTrace := "L-H-Y"
            return new target.airdodge.horizontalModY
        } else {
            lastCoordTrace := "L-H"
            return new target.airdodge.horizontal
        }
    }
}

getAnalogCoordsFirefox() {
    global
    if (modX()) {
        if (cUp()) {
            lastCoordTrace := "F-X-U"
            return buttonB ? new target.extendedB.modXCUp : new target.fireFox.modXCUp
        } else if (cDown()) {
            lastCoordTrace := "F-X-D"
            return buttonB ? new target.extendedB.modXCDown : new target.fireFox.modXCDown
        } else if (cLeft()) {
            lastCoordTrace := "F-X-L"
            return buttonB ? new target.extendedB.modXCLeft : new target.fireFox.modXCLeft
        } else if (cRight()) {
            lastCoordTrace := "F-X-R"
            return buttonB ? new target.extendedB.modXCRight : new target.fireFox.modXCRight
        } else {
            lastCoordTrace := "F-X"
            ; if buttonB
            return new target.extendedB.modX
        }
    } else if (modY()) {
        if (cUp()) {
            lastCoordTrace := "F-Y-U"
            return buttonB ? new target.extendedB.modYCUp : new target.fireFox.modYCUp
        } else if (cDown()) {
            lastCoordTrace := "F-Y-D"
            return buttonB ? new target.extendedB.modYCDown : new target.fireFox.modYCDown
        } else if (cLeft()) {
            lastCoordTrace := "F-Y-L"
            return buttonB ? new target.extendedB.modYCLeft : new target.fireFox.modYCLeft
        } else if (cRight()) {
            lastCoordTrace := "F-Y-R"
            return buttonB ? new target.extendedB.modYCRight : new target.fireFox.modYCRight
        } else {
            lastCoordTrace := "F-Y"
            ; if buttonB
            return new target.extendedB.modY
        }
    }
}

