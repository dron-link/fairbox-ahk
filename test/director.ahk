#Requires AutoHotkey v1.1

#include %A_ScriptDir%\test\coordinates
;#include, testBringToOctagonGate.ahk
;#include, testTrimToCircle.ahk

#include %A_ScriptDir%\test\limitOutputs\closing
#include, fCrouchDetector.ahk
#include, fCrouchDetectorUndershoot.ahk
#include, fDashDetector.ahk
#include, fDashDetectorUndershoot.ahk
#include, fExpectedOutputHist.ahk
#include, fFlushCandidates.ahk
#include, fOutOfDeadzoneDetector.ahk
#include, fOutOfDeadzoneDetectorUndershoot.ahk
#include, fSavedZoneNotInQZero.ahk
#include, fUnsavedZoneZero.ahk

#include %A_ScriptDir%\test\limitOutputs
;#include, inputsOvertake.ahk
;#include, testGetFuzzyHorizontal100.ahk
#include, testGetOutputLimited.ahk

#include %A_ScriptDir%\test\system
#include, testFairboxConstants.ahk
#include, testGameEngineConstants.ahk

#include %A_ScriptDir%\test
#include, logAppend.ahk
;#include, testNerfsByHand.ahk

testStage := ""

endOfLaunchThreadTests() {
    global enabledHotkeys

    Menu, Tray, Add, % "CARRY TESTS AND EXIT APP", exitAppTests ; it's necessary to access exitAppTests()

    if !enabledHotkeys {
        TrayTip, % "FAIRBOX", % "TEST MODE", 3, 0
        testGetOutputLimited()
        ExitApp
    }
    else {
        ; tests that run while the user is playing go here
        
    }
    return
}

exitAppTests() {
    testFairboxConstants()
    testGameEngineConstants()
    ExitApp
}

