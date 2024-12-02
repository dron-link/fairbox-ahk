#Requires AutoHotkey v1.1

fSavedZoneNotInQZero(results) {
    if IsObject(results.outOfDeadzone.up.candidates[0]) {
        OutputDebug, "savedZoneNotInQZero warning #1. something was not expected`n"
    }
    if IsObject(results.outOfDeadzone.down.candidates[0]) {
        OutputDebug, "savedZoneNotInQZero warning #2. something was not expected`n"
    }
    if IsObject(results.crouchZone.candidates[0]) {
        OutputDebug, "savedZoneNotInQZero warning #3. something was not expected`n"
    }
    if IsObject(results.dashZone.candidates[0]) {
        OutputDebug, "savedZoneNotInQZero warning #4. something was not expected`n"
    }

    OutputDebug, % "savedZoneNotInQZero test finish`n`n"
    return
}