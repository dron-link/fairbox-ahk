#Requires AutoHotkey v1.1

; //////////////// Get CStick coordinates. unit circle format
getCStickCoords() {
    if anyVertC() {
        if anyHorizC() {
            return reflectCStickCoords([42, 68]) 
        } else {
            return reflectCStickCoords([0, 80]) 
        }
    } else if anyHorizC() {
        if (modX() and up()) { ; mod X + up with the leftstick
            return [cLeft()? -72 : 72, 40] ; up-angled fsmash
        } else if (modX() and down()) { ; mod X + down with the leftstick
            return [cLeft()? -72 : 72, -40] ; down-angled fsmash
        } ; else
        return reflectCStickCoords([80, 0]) 
    } ; else
    return [0, 0]
}

reflectCStickCoords(quadrantIMirrorCoords) {
    global xComp, global yComp
    x := quadrantIMirrorCoords[xComp], y := quadrantIMirrorCoords[yComp]
    return [cLeft()? -x : x, cDown()? -y : y]
}