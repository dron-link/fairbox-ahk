#Requires AutoHotkey v1

; /////////////// Creates the Debug message. (Troubleshooting)
getDebug() {
    global buttonUp, global buttonDown, global buttonLeft, global buttonRight
    global buttonModX, global buttonModY, global buttonA, global buttonB
    global buttonL, global buttonR, global buttonX, global buttonY, global buttonZ
    global buttonCUp, global buttonCDown, global buttonCLeft, global buttonCRight
    global buttonLightShield, global buttonMidShield, global opposingHorizontalsModLockout

    activeArray := []
    pressedArray := []
    flagArray := []

    appendButtonState(activeArray, pressedArray, up(), buttonUp, "Up")
    appendButtonState(activeArray, pressedArray, down(), buttonDown, "Down")
    appendButtonState(activeArray, pressedArray, left(), buttonLeft, "Left")
    appendButtonState(activeArray, pressedArray, right(), buttonRight, "Right")

    appendButtonState(activeArray, pressedArray, modX(), buttonModX, "ModX")
    appendButtonState(activeArray, pressedArray, modY(), buttonModY, "ModY")

    appendButtonState(activeArray, pressedArray, buttonA, false, "A")
    appendButtonState(activeArray, pressedArray, buttonB, false, "B")
    appendButtonState(activeArray, pressedArray, buttonL, false, "L")
    appendButtonState(activeArray, pressedArray, buttonR, false, "R")
    appendButtonState(activeArray, pressedArray, buttonX, false, "X")
    appendButtonState(activeArray, pressedArray, buttonY, false, "Y")
    appendButtonState(activeArray, pressedArray, buttonZ, false, "Z")

    appendButtonState(activeArray, pressedArray, buttonLightShield, false, "LightShield")
    appendButtonState(activeArray, pressedArray, buttonMidShield, false, "MidShield")

    appendButtonState(activeArray, pressedArray, CUp(), buttonCUp, "C-Up")
    appendButtonState(activeArray, pressedArray, CDown(), buttonCDown, "C-Down")
    appendButtonState(activeArray, pressedArray, CLeft(), buttonCLeft, "C-Left")
    appendButtonState(activeArray, pressedArray, CRight(), buttonCRight, "C-Right")

    conditionalAppend(flagArray, opposingHorizontalsModLockout, "SHML") 

    activeButtonList := stringJoin(", ", activeArray)
    pressedButtonList := stringJoin(", ", pressedArray)
    flagList := stringJoin(", ", flagArray)

    trace1 := lastCoordTrace

    analogCoordsDbg := getAnalogCoords()
    cStickCoordsDbg := getCStickCoords()

    trace2 := lastCoordTrace

    trace := trace1 == trace2 ? trace1 : Format("{1}/{2}", trace1, trace2)

    debugFormatString =
    (

        Analog Stick: [{1}, {2}]
        C Stick: [{3}, {4}]

        Active held buttons:
        {5}

        Disabled held buttons:
        {6}

        Flags:
        {7}

        Trace:
    {8}
    )

    return Format(debugFormatString
    , analogCoordsDbg[1], analogCoordsDbg[2]
    , cStickCoordsDbg[1], cStickCoordsDbg[2]
    , activeButtonList, pressedButtonList, flagList
    , trace)
}

appendButtonState(activeArray, pressedArray, isActive, isPressed, name) {
    if (isActive) {
        activeArray.Push(name)
    } else if (isPressed) {
        pressedArray.Push(name)
    }
}

conditionalAppend(array, condition, value) {
    if (condition) {
        array.Push(value)
    }
}

; From https://www.autohotkey.com/boards/viewtopic.php?t=7124
stringJoin(sep, params) {
    str := ""
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}

