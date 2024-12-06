#Requires AutoHotkey v1.1

getOutputLimited(rawAX, rawAY) { ; Get coordinates but now with nerfs
    global TIMELIMIT_SIMULTANEOUS
    global xComp, global yComp, global currentTimeMS

    ; ### first call setup

    static output := new outputTrackAndNerfObject
    ; objects that store the info of previous relevant areas the control stick was inside of
    static outOfDeadzone := {up: new directionDeadzoneHistoryObject, down: new directionDeadzoneHistoryObject}
    static dashZone := new dashZoneHistoryObject
    static crouchZone := new crouchZoneHistoryObject

    ; ### update the variables

    /*  true if current input and those that follow can't be considered as part of the previous 
        simultaneous multiple key presses event;
        only runs once, after a multipress ends.
    */
    if (currentTimeMS - output.latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS
        and !output.hist[1].multipress.ended) {
        output.hist[1].multipress.ended := true
        outOfDeadzone.up.saveHistory()
        outOfDeadzone.down.saveHistory()
        crouchZone.saveHistory()
        dashZone.saveHistory()   
    }

    ; create an object that stores the current output info
    output.limited := new outputHistoryEntry(rawAX, rawAY, currentTimeMS, output.hist[1].multipress.ended)

    ; ### processes the player input and converts it into legal output

    output.turnaroundNeutralBNerf()

    ; if technique needs to be nerfed, this writes the nerfed coordinates in nerfedCoords
    output.dashTechniqueNerfSearch(dashZone, outOfDeadzone, output.limited.x, output.limited.y)
    output.crouchTechniqueNerfSearch(crouchZone, output.limited.x, output.limited.y)

    output.chooseLockout()

    ; fuzz the y when x is +1.00 or -1.00
    output.horizontalRimFuzz()

    ; ### record output to read it in next calls of this function

    if (output.limited.x != output.hist[1].x or output.limited.y != output.hist[1].y) {
        ; store analog zones' info
        outOfDeadzone.up.recordDeadzoneOutput(getIsOutOfDeadzoneUp(output.limited.y))
        outOfDeadzone.down.recordDeadzoneOutput(getIsOutOfDeadzoneDown(output.limited.y))
        crouchZone.recordCrouchOutput(getCrouchZoneOf(output.limited.y))
        dashZone.recordDashOutput(getDashZoneOf(output.limited.x))

        /*  if true, the input to be stored will be either a lone key press/lift or the beginning of a
            simultaneous multiple keypress event (aka multipress)
        */
        if output.limited.multipress.began {
            output.latestMultipressBeginningTimestamp := output.limited.timestamp ; obviously, currentTimeMS
        }
        ; registers even the shortest-lasting leftstick coordinates passed to vjoy
        output.hist.Pop(), output.hist.InsertAt(1, output.limited)
    }

    return output.limited
}