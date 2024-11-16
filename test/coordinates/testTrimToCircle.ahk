#Requires AutoHotkey v1.1

testTrimToCircle() {
    global ANALOG_STICK_MAX, global xComp, global yComp
    OutputDebug, % "testTrimToCircle() to start. Results go into log file.`n"
    logAppend("`ntestTrimToCircle()")
    x := -128
    Loop {
        y := -128
        Loop {
            trimmedCoords := trimToCircle([x, y])
            trimX := trimmedCoords[xComp], trimY := trimmedCoords[yComp]
            if (x != trimX or y != trimY) { ; detect a change
                ; if coordinates' radius go beyond the unit circle
                if (trimX**2 + trimY**2 > ANALOG_STICK_MAX**2) {
                    logAppend("overshoot. x " x " y " y " trimX " trimX " trimY " trimY)
                }
                /*  if coordinates' radius is equal or falls below the radius of the farthest 
                    coordinates that are not yet on the border (estimate by dron-link)
                */
                else if (trimX**2 + trimY**2 <= 56**2 + 55**2) {
                    logAppend("undershoot. x " x " y " y " trimX " trimX " trimY " trimY)
                }
            }
            ; if the coordinates went unaltered and are beyond the unit circle
            else if (x**2 + y**2 > ANALOG_STICK_MAX**2) {
                logAppend("Input wrongly ignored. x " x " y " y " trimX " trimX " trimY " trimY)
            }
            y += 1
        } Until y > 128
        x += 1
    } Until x > 128

    logAppend("testTrimToCircle(): test concluded.`n")

    return
}
