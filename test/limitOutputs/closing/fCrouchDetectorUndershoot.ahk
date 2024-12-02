#Requires AutoHotkey v1.1

fCrouchDetectorUndershoot(results) {
    for i in results.crouchZone.candidates {
        OutputDebug, % "crouchDetectorUndershoot warning. something was not expected`n"
        break
    }
    OutputDebug, % "crouchDetectorUndershoot test finish`n`n"
    return
}