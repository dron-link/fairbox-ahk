#Requires AutoHotkey v1.1

; dependency: detectNonIntegers()

testTrimToCircle() {
    global
    Loop, 256 {
        testX := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
        Loop, 256 {
            testY := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
            testCoordinates := trimToCircle([testX, testY])
            ; detect a change
            if (testCoordinates[xComp] != testX or testCoordinates[yComp] != testY) {
                ; if coordinates' radius go beyond the unit circle
                if (testCoordinates[xComp]**2 + testCoordinates[yComp]**2 > ANALOG_STICK_MAX**2) {
                    OutputDebug, % "testTrimToCircle(): overshoot "
                        . testX " " testY "`n" testCoordinates[xComp] " " testCoordinates[yComp] "`n"
                }
                /*  if coordinates' radius is equal or falls below the radius of the farthest 
                    coordinates that are not yet on the border
                */
                if (testCoordinates[xComp]**2 + testCoordinates[yComp]**2 <= 56**2 + 55**2) {
                    OutputDebug, % "testTrimToCircle(): undershoot "
                        . testX " " testY "`n" testCoordinates[xComp] " " testCoordinates[yComp] "`n"
                }
            }
            ; if the coordinates went unaltered and are beyond the unit circle
            else if (testCoordinates[xComp]**2 + testCoordinates[yComp]**2 > ANALOG_STICK_MAX**2) {
                OutputDebug, % "testTrimToCircle(): ignored or didn't change coord out of circle "
                    . testX " " testY "`n" testCoordinates[xComp] " " testCoordinates[yComp] "`n"
            }

        }
    }
    OutputDebug, % "testTrimToCircle(): test concluded`n"

    return
}
