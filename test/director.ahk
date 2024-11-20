#Requires AutoHotkey v1.1

#include %A_ScriptDir%\test\coordinates
;#include, testBringToOctagonGate.ahk
;#include, testTrimToCircle.ahk

#include %A_ScriptDir%\test\limitOutputs
#include, testGetFuzzyHorizontal100.ahk

#include %A_ScriptDir%\test\system
#include, testFairboxConstants.ahk
#include, testGameEngineConstants.ahk

#include %A_ScriptDir%\test
#include, logAppend.ahk

testStage := ""

endOfLaunchThreadTests() {
    global enabledHotkeys
    Critical
    Menu, Tray, Add, % "CARRY TESTS AND EXIT APP", exitAppTests ; it's necessary to access exitAppTests()
    
    if !enabledHotkeys {
        TrayTip, % "FAIRBOX", % "TEST MODE", 3, 0

        ExitApp
    }   
    Critical Off
}

exitAppTests() {
    testFairboxConstants()
    testGameEngineConstants()
    ExitApp
}
