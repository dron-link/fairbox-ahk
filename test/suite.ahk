#Requires AutoHotkey v1.1

#include logAppend.ahk

#include %A_ScriptDir%\test\system
#include, testFairboxConstants.ahk
#include, testGameEngineConstants.ahk

#include %A_ScriptDir%\test\limitOutputs
#include testGetFuzzyHorizontal100.ahk

testStage := ""

endOfLaunchThreadTests() {
    global enabledHotkeys
    Critical
    Menu, Tray, Add, % "CARRY TESTS AND EXIT APP", exitAppTests ; it's necessary to access exitAppTests()
    
    if !enabledHotkeys {
        TrayTip, % "FAIRBOX", % "TEST MODE", 3, 0
        testGetFuzzyHorizontal100()
        ExitApp
    }   
    Critical Off
}

exitAppTests() {
    testFairboxConstants()
    testGameEngineConstants()
    ExitApp
}
