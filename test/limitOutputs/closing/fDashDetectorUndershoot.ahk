#Requires AutoHotkey v1.1

fDashDetectorUndershoot(results) {
    for i in results.dashZone.candidates {
        OutputDebug, % "dashDetectorUndershoot warning #1. something was not expected`n"
        break
    }

    OutputDebug, % "dashDetectorUndershoot test finish`n`n"
    return
}