#Requires AutoHotkey v1.1

getPivotNerfedCoords(coords, outOfDeadzone, pivotCompletionInfo) {
    global ANALOG_STICK_MAX, global FORCE_FTILT
    global TIMELIMIT_TAPSHUTOFF, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_PIVOTTILT_YDASH
    global P_RIGHTLEFT, global P_LEFTRIGHT, global xComp, global yComp, global currentTimeMS
    ; early Returns ahead.

    if (currentTimeMS - pivotCompletionInfo.timestamp >= TIMELIMIT_PIVOTTILT or !pivotCompletionInfo.pivot) {
        return false ; No pivot or all pivot nerfs expired.
    }
    ; else, if we are within the nerf time window:

    aX := coords[xComp], aY := coords[yComp]

    ; ### UP
    upYDeadzone := getCurrentOutOfDeadzoneInfo(outOfDeadzone.up.saved, outOfDeadzone.up.candidate
    , getIsOutOfDeadzoneUp(aY))
    /*  if we are in the up region
        and the player has not shut off tap jump
        or the player has shut off tap jump but not with actions done before
        completing the pivot (upY dashes)
    */
    if (upYDeadzone.out and (currentTimeMS - upYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF
        or upYDeadzone.timestamp >= pivotCompletionInfo.timestamp)) {
        if (Abs(aX) > aY) {
            /*  //Force all upward angles to a minimum of 45deg away from the horizontal
                //to prevent pivot uftilt and ensure tap jump
            */
            return bringToCircleBorder([aX > 0 ? 128 : -128, 128]) ; [+/-128, 128]: 45 degrees
        } 
        ; else
        return bringToCircleBorder(coords)
    }
    /*  if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes.
        nerf only active for TIMELIMIT_PIVOTTILT_YDASH ms after pivot (5 frames total as of writing this)
    */
    if (upYDeadzone.out and currentTimeMS - pivotCompletionInfo.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
        /*  if P_RIGHTLEFT then negative X
            if P_LEFTRIGHT then positive X
            apparently CarVac uses the opposite x directions for the ftilt.
            what does the proposal team mean when saying pressing A too early as a failure state?
        */
        return [pivotCompletionInfo.pivot == P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT, FORCE_FTILT]
    }

    ; ### DOWN
    downYDeadzone := getCurrentOutOfDeadzoneInfo(outOfDeadzone.down.saved, outOfDeadzone.down.candidate
    , getIsOutOfDeadzoneDown(aY))
    ; if the player hasn't shut off tap downsmash
    if (downYDeadzone.out and currentTimeMS - downYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF) {
        return bringToCircleBorder(coords)
    }

    ; if the player shut off tap downsmash, by pivoting with downY dashes
    if (downYDeadzone.out and downYDeadzone.timestamp < pivotCompletionInfo.timestamp
        and currentTimeMS - pivotCompletionInfo.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
        return [pivotCompletionInfo.pivot == P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT, -FORCE_FTILT]
    }
    ; if the player shut off tap downsmash without pivoting with downY dashes we refrain from nerfing.

    return false ; if we reach this, no conditions for applying nerfs were fulfilled
}