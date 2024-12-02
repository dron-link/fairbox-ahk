#Requires AutoHotkey v1.1

fDashDetector(expectedZone, results) {
    global ZONE_L, global ZONE_R
    static phase := 1

    if (results.dashZone.unsaved.zone != expectedZone) {
        OutputDebug, % "dashDetector warning #1. "
        . "phase " phase " expectedZone " expectedZone
        . ": something was not expected`n"
    }
    if (results.dashZone.candidates[expectedZone].zone != expectedZone) {
        OutputDebug, % "dashDetector warning #2. " 
        . "phase " phase " expectedZone " expectedZone
        . ": something was not expected`n"
    }

    if (phase == 1) {
        for i, element in results.dashZone.candidates {
            if (element != results.dashZone.candidates[expectedZone]) {
                OutputDebug, % "dashDetector warning #4. something was not expected`n"
                break
            }
        }

        phase += 1
    }

    else if (phase == 2) {
        ; tally to check if both L and R made it
        tally := 0
        for i, element in results.dashZone.candidates {
            tally += element.zone
        }
        if (tally != ZONE_L + ZONE_R) {
            OutputDebug, % "dashDetector warning #5. something was not expected`n"
        }
        
        OutputDebug, % "dashDetector test finish`n`n"
    }


    return
}