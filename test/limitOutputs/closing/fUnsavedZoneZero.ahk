#Requires AutoHotkey v1.1

fUnsavedZoneZero(results) {
    if (results.outOfDeadzone.up.unsaved.out != 0) {
        OutputDebug, % "unsavedZoneZero warning #1. something was not expected`n"
    }
    if (results.outOfDeadzone.down.unsaved.out != 0) {
        OutputDebug, % "unsavedZoneZero warning #2. something was not expected`n"
    }
    if (results.crouchZone.unsaved.zone != 0) {
        OutputDebug, % "unsavedZoneZero warning #3. something was not expected`n"
    }
    if (results.dashZone.unsaved.zone != 0) {
        OutputDebug, % "unsavedZoneZero warning #4. something was not expected`n"
    }

    OutputDebug, % "unsavedZoneZero test finish`n`n" 
}