#Requires AutoHotkey v1

getPivotNerfedCoords(condition, coords) {
    global PNERF_EXTEND, global PNERF_UP_45DEG
    global PNERF_YDASH_RIGHTLEFT, global PNERF_YDASH_LEFTRIGHT
    global FORCE_FTILT, global xComp, global yComp

    Switch condition
    {
        Case PNERF_EXTEND:
            return bringToCircleBorder(coords)
        Case PNERF_UP_45DEG:
            Return bringToCircleBorder([coords[xComp] > 0 ? 128 : -128, 128]) ; [+/-128, 128]: 45 degrees
        Case PNERF_YDASH_RIGHTLEFT:
            Return [-FORCE_FTILT, coords[yComp] > 0 ? FORCE_FTILT : -FORCE_FTILT]
        Case PNERF_YDASH_LEFTRIGHT:
            Return [FORCE_FTILT, coords[yComp] > 0 ? FORCE_FTILT : -FORCE_FTILT]
        Case false:
            Return coords
    }
    ; else
    OutputDebug, % "getPivotNerfedCoords() Case not accounted for. Please find what caused this!`n"
    return
}