#Requires AutoHotkey v1.1

getPivotNerfedCoords(condition, coords) {
    global FORCE_FTILT
    global PNERF_EXTEND, global PNERF_UP_45DEG
    global PNERF_YDASH_RIGHTLEFT, global PNERF_YDASH_LEFTRIGHT
    global xComp, global yComp

    Switch condition
    {
        Case PNERF_EXTEND:
            return bringToCircleBorder(coords)
        Case PNERF_UP_45DEG:
            aX := coords[xComp]
            Return bringToCircleBorder([aX > 0 ? 128 : -128, 128]) ; [+/-128, 128]: 45 degrees
        Case PNERF_YDASH_RIGHTLEFT:
            aY := coords[yComp]
            Return [-FORCE_FTILT, aY > 0 ? FORCE_FTILT : -FORCE_FTILT]
        Case PNERF_YDASH_LEFTRIGHT:
            aY := coords[yComp]
            Return [FORCE_FTILT, aY > 0 ? FORCE_FTILT : -FORCE_FTILT]
    }
    ; else
    OutputDebug, % "getPivotNerfedCoords() Nonexistent Case. Please check!`n"
    return
}