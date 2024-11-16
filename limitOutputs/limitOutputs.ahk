#Requires AutoHotkey v1.1

#include, getFuzzyHorizontal100.ahk
#include, limitedOutputsObject.ahk
;;; this
#include, output.ahk

limitOutputs(aX, aY) { ; ///////////// Get coordinates but now with nerfs
    global TIMELIMIT_SIMULTANEOUS, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_DOWNUP, global ZONE_CENTER
    global xComp, global yComp, global currentTimeMS

    ; ### first call setup

    static output := new limitedOutputsObject
    ; objects that store the info of previous relevant areas the control stick was inside of
    static outOfDeadzone := {up: new upDeadzoneHistoryObject, down: new downDeadzoneHistoryObject}
    static dashZone := new dashZoneHistoryObject
    static crouchZone := new crouchZoneHistoryObject
    ; objects that store the previously executed techniques that activate timing lockouts
    static pivot := new pivotTrackAndNerfObject
    static uncrouch := new uncrouchTrackAndNerfObject

    ; ### update the variables

    output.limited := new outputHistoryEntry(aX, aY, currentTimeMS)
    /*  true if current input and those that follow can't be considered as part of the previous multipress;
        only runs once, after a multipress ends.
    */
    if (currentTimeMS - output.latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS
        and !output.hist[1].multipress.ended) {
        output.hist[1].multipress.ended := true
        outOfDeadzone.up.saveHistory()
        outOfDeadzone.down.saveHistory()
        crouchZone.saveHistory()
        uncrouch.saveHistory()
        dashZone.saveHistory()
        pivot.saveHistory()
    }
    uncrouch.lockoutExpiryCheck()
    dashZone.checkHistoryEntryStaleness() ; marks some entries as stale for pivot execution
    pivot.lockoutExpiryCheck()

    ; ### processes the player input and converts it into legal output

    output.reverseNeutralBNerf()

    ; if technique needs to be nerfed, this writes the nerfed coordinates in nerfedCoords
    pivot.nerfSearch(output.limited.x, output.limited.y, dashZone, outOfDeadzone)
    uncrouch.nerfSearch(output.limited.x, output.limited.y, crouchZone)

    output.chooseLockout(pivot, uncrouch)

    ; fuzz the y when x is +1.00 or -1.00
    output.horizontalRimFuzz()

    ; ### record output to read it in next calls of this function

    uncrouch.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y, crouchZone)
    pivot.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y, dashZone)

    if (output.limited.x != output.hist[1].x or output.limited.y != output.hist[1].y) {
        ; store analog zones' info
        outOfDeadzone.up.storeInfoBeforeMultipressEnds(output.limited.y)
        outOfDeadzone.down.storeInfoBeforeMultipressEnds(output.limited.y)
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