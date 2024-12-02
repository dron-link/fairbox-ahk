#Requires AutoHotkey v1.1

testGetOutputLimited() {
    global
    currentTimeMS := 0



    /*  test output hist entry creation
        check that the real history size is no different than outputHistoryObject.historyLength

        check that entries should only get added once coordinates are different from
        last saved ones (every entry's coordinates will be different from those of adjacent entries)
    */
    OutputDebug, % "expectedOutputHist test`n"

    getOutputLimited(0,0)

    getOutputLimited(2,0)   ; we chose pretty safe coordinates and movements
    getOutputLimited(2,0)   ; that don't register as analog zone changes.
                            ; repeated values should not end up occupying
                            ; multiple history slots

    getOutputLimited(2,2)

    getOutputLimited(0,2)
    getOutputLimited(0,2)
    getOutputLimited(0,2)

    getOutputLimited(0,-2)

    getOutputLimited(-2,-2)

    getOutputLimited(-2,0)
    getOutputLimited(-2,0)

    fExpectedOutputHist(fullInfoExtract(0,0))
    
    /*  test out of deadzone detector
        Undershoot
        
        we don't move away from current deadzone... if that is true, no entries should appear in candidates
    */
    OutputDebug, % "outOfDeadzoneDetectorUndershoot test`n"
    getOutputLimited(0, ANALOG_DEAD_MIN)
    fOutOfDeadzoneDetectorUndershoot(fullInfoExtract(0, ANALOG_DEAD_MAX))

    /*  test out of deadzone detector
        normal
    */
    OutputDebug, % "outOfDeadzoneDetector test`n"
    fOutOfDeadzoneDetector("down", fullInfoExtract(0, ANALOG_DEAD_MIN - 1))
    fOutOfDeadzoneDetector("up", fullInfoExtract(0, ANALOG_DEAD_MAX + 1))

    /*  test crouch detector
        Undershoot    
        
        i put this after the outOfDeadzone detector. if I put
        it before, I would inadvertently alter outOfDeadzone.down
        because crouch movement occurs over a wider stick range than deadzone exit movement,
        so, IsOutOfDeadzone_down would end picking up that
    */
    OutputDebug, % "crouchDetectorUndershoot test`n"
    getOutputLimited(0, 80) ; trip on mistake of using inverted sign
    fCrouchDetectorUndershoot(fullInfoExtract(0, ANALOG_CROUCH + 1)) ; short of holding crouch
    
    /*  test crouch detector
        normal
    */
    OutputDebug, % "crouchDetector test`n"
    fCrouchDetector(fullInfoExtract(0, ANALOG_CROUCH))

    /*  test dash detector
        undershoot
    */
    OutputDebug, % "dashDetectorUndershoot test`n"
    getOutputLimited(ANALOG_DASH_LEFT + 1, 0) ; short of left
    fDashDetectorUndershoot(fullInfoExtract(ANALOG_DASH_RIGHT - 1, 0)) ; short of right

    /*  test dash detector
        normal
    */
    OutputDebug, % "dashDetector test`n"
    fDashDetector(ZONE_L, fullInfoExtract(ANALOG_DASH_LEFT, 0))
    fDashDetector(ZONE_R, fullInfoExtract(ANALOG_DASH_RIGHT, 0))

    /*  no existence of saved zone IN CANDIDATES test (as all saved zones are in center and none out of deadzone,
        we verify that !IsObject(candidates[0]) and that's it)
    */
    OutputDebug, % "savedZoneNotInQZero test`n"
    fSavedZoneNotInQZero(fullInfoExtract(0, 0))

    /*  test that all Unsaved are centered
        we already checked that all zones show up on unsaved, except we didn't check center
    */
    OutputDebug, % "unsavedZoneZero test`n" 
    fUnsavedZoneZero(fullInfoExtract(0, 0))

    /*  test history saving
        flush candidates. check that candidate arrays are empty
    */
    OutputDebug, % "flushCandidates test`n" 
    currentTimeMS += TIMELIMIT_SIMULTANEOUS
    fFlushCandidates(fullInfoExtract(0, 0))

    return
}

fullInfoExtract(x, y) {
    global getOutputLimitedReturnAllObjects
    getOutputLimitedReturnAllObjects := true
    extract := getOutputLimited(x, y)
    getOutputLimitedReturnAllObjects := false
    return extract
}

breakpointView(x, y) {
    extract := fullInfoExtract(x, y)
    ; you should place a breakpoint here
    return
}

