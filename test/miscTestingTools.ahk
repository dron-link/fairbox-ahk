#Requires AutoHotkey v1.1

pivotLiveDebugMessages(result, pivotDiscarded) { ; called by detectPivot() when pivotDebug == true
    global P_RIGHTLEFT, global P_LEFTRIGHT
    Switch pivotDiscarded
    {
    Case false:
        if (result == P_LEFTRIGHT) {
            OutputDebug, % "P_LEFTRIGHT`n"
        } else if (result == P_RIGHTLEFT) {
            OutputDebug, % "P_RIGHTLEFT`n"
        }
    Case 1:
        OutputDebug, % "check #1 stale, no pivot`n"
    Case 2:
        OutputDebug, % "check #2 length, no pivot`n"
    }
    return
}

testTrimToCircle() {
    global

    Loop, 256 {
        testX := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
        Loop, 256 {
            testY := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
            testCoordinates := trimToCircle(testX, testY)
            if (testCoordinates[1] != testX or testCoordinates[2] != testY) {
                if (testCoordinates[1]**2 + testCoordinates[2]**2 > ANALOG_STICK_MAX**2) {
                    OutputDebug, % "trimToCircle overshoot "
                        . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
                }
                if (testCoordinates[1]**2 + testCoordinates[2]**2 <= 56**2 + 55**2) {
                    OutputDebug, % "trimToCircle undershoot "
                        . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
                }
            } else if (testCoordinates[1]**2 + testCoordinates[2]**2 > ANALOG_STICK_MAX**2) {
                OutputDebug, % "trimToCircle ignored or didn't change coord out of circle "
                    . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
            }

        }
    }
    OutputDebug, % "trimToCircle test concluded"

    return
}

detectNonIntegers(aX, aY) {
    if aX is not Integer
        OutputDebug, detectNonIntegers() problem . coordinate x type is not integer`n
    if aY is not Integer
        OutputDebug, detectNonIntegers() problem . coordinate y type is not integer`n
    return
}