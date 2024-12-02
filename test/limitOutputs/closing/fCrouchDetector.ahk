#Requires AutoHotkey v1.1

fCrouchDetector(results) {
    global ZONE_D
    if (results.crouchZone.candidates[ZONE_D].zone != ZONE_D) {
        OutputDebug, % "crouchDetector warning #1. something was not expected`n"
    }

    for i, element in results.crouchZone.candidates {
        if (element != results.crouchZone.candidates[ZONE_D]) {
            OutputDebug, % "crouchDetector warning #2. something was not expected`n"
            break
        }
    }
    OutputDebug, % "crouchDetector test finish`n`n"
    return
}