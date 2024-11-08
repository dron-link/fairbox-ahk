#Requires AutoHotkey v1.1

limitOutputs(rawCoords) { ; ///////////// Get coordinates but now with nerfs
    global TIMELIMIT_SIMULTANEOUS, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_DOWNUP, global ZONE_CENTER
    global xComp, global yComp, global currentTimeMS

    ; ### first call setup

    static output := new outputBase
    ; objects that store the info of previous relevant areas the control stick was inside of
    static outOfDeadzone := new leftstickOutOfDeadzoneBase
    static dashZone := new dashZoneHistoryObject
    static crouchZone := new crouchZoneHistoryObject
    ; objects that store the previously executed techniques that activate timing lockouts
    static pivot := new pivotTrackAndNerfObject
    static uncrouch := new uncrouchTrackAndNerfObject

    static limitOutputsInitialized := False
    if !limitOutputsInitialized {
        /*  this is a way to bundle outOfDeadzone info with the pivot and uncrouch objects
            to make the info visible to pivot.getNerfedCoords() and uncrouch.getNerfedCoords()
        */
        ;
        pivot.outOfDeadzone := outOfDeadzone
        uncrouch.outOfDeadzone := outOfDeadzone
        limitOutputsInitialized := True
    }

    ; ### update the variables

    output.limited := new outputHistoryEntry(rawCoords[xComp], rawCoords[yComp], currentTimeMS)
    /*  true if current input and those that follow can't be considered as part of the previous multipress;
        only runs once, after a multipress ends.
    */
    if (currentTimeMS - output.latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS
        and !output.hist[1].multipress.ended) {
        output.hist[1].multipress.ended := true
        outOfDeadzone.saveHistory()
        crouchZone.saveHistory()
        uncrouch.saveHistory()
        dashZone.saveHistory()
        pivot.saveHistory()
    }
    uncrouch.lockoutExpiryCheck()
    dashZone.checkHistoryEntryStaleness()
    pivot.lockoutExpiryCheck()

    ; ### processes the player input and converts it into legal output

    output.reverseNeutralBNerf()

    ; if technique needs to be nerfed, this writes the nerfed coordinates in nerfedCoords
    pivot.nerfSearch(output.limited.x, output.limited.y, dashZone)
    uncrouch.nerfSearch(output.limited.x, output.limited.y, crouchZone)

    output.chooseLockout(pivot, uncrouch)

    ; fuzz the y when x is +1.00 or -1.00
    output.horizontalRimFuzz()

    ; ### record output to read it in next calls of this function

    uncrouch.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y, crouchZone)
    pivot.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y, dashZone)

    if (output.limited.x != output.hist[1].x or output.limited.y != output.hist[1].y) {
        outOfDeadzone.storeInfoBeforeMultipressEnds(output.limited.y)
        crouchZone.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y)
        dashZone.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y)

        ; if true, next input to be stored is potentially the beginning of a simultaneous multiple key press (aka multipress)
        if output.hist[1].multipress.ended {
            output.limited.multipress.began := true
            output.latestMultipressBeginningTimestamp := output.limited.timestamp ; obviously, currentTimeMS
        }
        ; registers even the shortest-lasting leftstick coordinates passed to vjoy
        output.hist.Pop(), output.hist.InsertAt(1, output.limited)
    }

    return output.limited
}