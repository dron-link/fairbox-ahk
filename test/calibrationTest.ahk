#Requires AutoHotkey v1.1

calibrationTest() {
    ; helps checking that the coordinates show up correctly in the game
    global

    stickResetCoords := convertIntegerToVJoy([0, 0])
    myStick.SetAxisByIndex(stickResetCoords[1], 1)
    myStick.SetAxisByIndex(stickResetCoords[2], 2)
    OutputDebug, % "calibrationTest begin`n"
    MsgBox, % "calibrationTest begin?"
    Loop, 50 {
        myStick.SetAxisByIndex(stickResetCoords[1], 1)
        myStick.SetAxisByIndex(stickResetCoords[2], 2)
        Sleep, 15
    }

    /* ; for using the stepper
    startIntended := 0
    endIntended := 10
    sleepTime := 1000
    rangeStepper(xComp, startIntended, endIntended, sleepTime)
    */
    /* ; for using the crawler
    startVJoy := 0
    endVJoy := 256
    sleepTime := 20
    rangeCrawler(YComp, startVJoy, endVJoy, sleepTime)
    */
    ; /* ; config test current convertIntegerToVJoy
    startIntended := 0
    endIntended := 10
    sleepTime := 1000
    ; test current convertIntegerToVJoy
    currentIntended := startIntended
    OutputDebug, % "testing current convertIntegerToVJoy. Please focus the game window by clicking on it"
    Loop, % Abs(endIntended - startIntended) + 1 {
        convertIntegerToVJoy([currentIntended, 0])
        OutputDebug, % currentIntended "`n"
        Sleep, sleepTime
        if (startIntended < endIntended) {
            currentIntended += 1
        } else if (startIntended > endIntended) {
            currentIntended -= 1
        }
    }
    ; */

    OutputDebug, % "calibrationTest end`n"
    Sleep, 1000
    myStick.SetAxisByIndex(stickResetCoords[1], 1)
    myStick.SetAxisByIndex(stickResetCoords[2], 2)
    OutputDebug, % "stick reset`n"
    ExitApp

    /*
      findings:
      FASTER MELEE / SLIPPI
        b0xx-ahk controller config
            ; To get an x coordinate ingame, the vjoy axis must be in the interval [axisMin, axisMax]
            if x <= -80
                axis <= 128*(-80) + 63
            if x in [-80 ... -1]
                axisMax = 128x + 63
            if x in [-79 ... 0]
                axisMin = 128x - 64
            if x in [0 ... 62]
                axisMax = 129x + 65
            if x in [1 ... 63]
                axisMin = 129x - 63
            if x in [63 ... 79]
                axisMax = 129x + 64
            if x in [64 ... 80]
                axisMin = 129x - 64
            if x >= 80
                axis >= 129*(80) - 64
            ; To get a y coordinate ingame, the vjoy axis must be in the interval [axisMin, axisMax]
            if y <= -80
                axis >= -129(-80) - 193
            if y in [-80 ... -65]
                axisMin = -129y - 193
            if y in [-79 ... -64]
                axisMax = -129y - 65
            if y in [-64 ... -2]
                axisMin = -129y - 192
            if y in [-63 ... -1]
                axisMax = -129y - 64
            if y = -1
                axisMin = 1
            if y = 0
                axisMax = 0
            if y in [0 ... 79]
                axisMin = -128y - 192
            if y in [1 ... 80]
                axisMax = -128y - 65
            if y >= 80
                axis <= -128*(80) - 65
    the convertIntegerToVJoy() return have to be kept fitted in these boundaries for
    fairbox-ahk to be precise in slippi
    */

    return
}

rangeStepper(axisIndex, startStep, endStep, sleepTime) {
    /*
    steps from a starting coordinate towards an ending coordinate,
    advancing through the vjoy axis range according to a function that converts game coordinate-->vjoy axis value
    */
    global
    OutputDebug, % "rangeStepper`n"
    stepTotal := Abs(endStep - startStep) + 1

    stepCurrent := startStep
    Loop, % stepTotal {
        if (axisIndex == xComp) {
            myStick.SetAxisByIndex(16384 + Round(128.63 * stepCurrent), xComp)
        } else if (axisIndex == yComp) {
            myStick.SetAxisByIndex(16384 - Round(128.38 * stepCurrent) - 83, yComp)
        }
        OutputDebug, % stepCurrent "`n"
        if (endStep >= startStep) {
            stepCurrent += 1
        } else if (endStep < startStep) {
            stepCurrent -= 1
        }
        Sleep, sleepTime
    }
    return
}

rangeCrawler(axisIndex, startAxis, endAxis, sleepTime) {
    /*
        advances from a axis position (relative to center) to another axis position,
        stopping in every possible value
    */
    global
    OutputDebug, % "rangeCrawler`n"
    axisTotal := Abs(endAxis - startAxis) + 1
    axisCurrent := startAxis
    Loop, % axisTotal {
        myStick.SetAxisByIndex(16384 + axisCurrent, axisIndex)
        OutputDebug, % axisCurrent "`n"
        if (endAxis >= startAxis) {
            axisCurrent += 1
        } else if (endAxis < startAxis) {
            axisCurrent -= 1
        }
        Sleep, sleepTime
    }
    return
}