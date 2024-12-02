#Requires AutoHotkey v1.1

fFlushCandidates(results) {
    for i in results.outOfDeadzone.up.candidates {
        OutputDebug, % "flushCandidates warning #1. something was not expected`n"
    }
    for i in results.outOfDeadzone.down.candidates {
        OutputDebug, % "flushCandidates warning #2. something was not expected`n"
    }
    for i in results.crouchZone.candidates {
        OutputDebug, % "flushCandidates warning #3. something was not expected`n"
    }
    for i in results.dashZone.candidates {
        OutputDebug, % "flushCandidates warning #4. something was not expected`n"
    }

    OutputDebug, % "flushCandidates test finish `n`n" 
}