#Requires AutoHotkey v1.1

fOutOfDeadzoneDetector(directionKey, results) {
    static phase := 1

    if !results.outOfDeadzone[directionKey].candidates[true].out {
        OutputDebug, % "outOfDeadzoneDetectorUndershoot warning #1. phase " 
        . phase " direction " directionKey
        . ": something was not expected`n"
    }
    if !results.outOfDeadzone[directionKey].unsaved.out {
        OutputDebug, % "outOfDeadzoneDetectorUndershoot warning #2. phase " 
        . phase " direction " directionKey
        . ": something was not expected`n"
    }

    ; if down.unsaved.out, it follows that !up.unsaved.out. the reverse occurs too
    if (directionKey = "up") {
        opposite := "down"
    } else if (directionKey = "down") {
        opposite := "up"
    }
    if results.outOfDeadzone[opposite].unsaved.out {
        OutputDebug, % "outOfDeadzoneDetectorUndershoot warning #3. phase " 
        . phase " direction " directionKey
        . ": something was not expected`n"
    }

    ; prepare for next phase or print the finish msg
    if (phase == 1) {
        phase += 1
    }
    else if (phase == 2) {
        OutputDebug, % "outOfDeadzoneDetector test finish`n`n"
    }
    return
}
