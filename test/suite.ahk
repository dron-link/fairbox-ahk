#Requires AutoHotkey v1.1

#include %A_ScriptDir%\test\system
#include, testFairboxConstants.ahk
#include, testGameEngineConstants.ahk

endOfLaunchThreadTests() {
    global enabledHotkeys
    Menu, Tray, Add, % "CARRY TESTS AND EXIT APP", exitAppTests ; it's necessary to access exitAppTests()
    testFairboxConstants()
    testGameEngineConstants()
    if !enabledHotkeys {
        TrayTip, % "FAIRBOX", % "TEST MODE", 3, 0
        
        ExitApp
    }   
}

exitAppTests() {
    testFairboxConstants()
    testGameEngineConstants()
    ExitApp
}
