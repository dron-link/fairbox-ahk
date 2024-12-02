#Requires AutoHotkey v1.1

fOutOfDeadzoneDetectorUndershoot(results) {
    for i in results.outOfDeadzone.up.candidates {
        OutputDebug, % "outOfDeadzoneDetectorUndershoot warning #1. something was not expected`n"
    }
    for i in results.outOfDeadzone.down.candidates {
        OutputDebug, % "outOfDeadzoneDetectorUndershoot warning #2. something was not expected`n"
    }
    OutputDebug, % "outOfDeadzoneDetectorUndershoot test finish`n`n"
    return
}