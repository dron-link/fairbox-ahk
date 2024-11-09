#Requires AutoHotkey v1.1

inputsOvertake() {
    global
    currentTimeMS := 1000
    uncrouchNerfDemo()
    ExitApp
    return
}

testOut(x, y, advanceTime) {
    global currentTimeMS
    currentTimeMS += advanceTime
    return limitOutputs(x, y)
}

; samples
uncrouchNerfDemo() {
    testOut(0, 0, 0)
    testOutput := testOut(0, 30, 32)
    if (testOutput.x == 0 and testOutput.y == 30) {
        OutputDebug, % "uptilt successful `n"
    } else {
        OutputDebug, % "FAIL `n"
    }

    testOut(0, 100, 0)
    testOut(0, -80, 100)
    testOutput := testOut(0, 30, 32)
    if (testOutput.x == 0 and testOutput.y == 80) {
        OutputDebug, % "uncrouch nerf successful `n"
    } else {
        OutputDebug, % "FAIL `n"
    }
}