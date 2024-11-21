#Requires AutoHotkey v1.1

getPivotLockoutNerfedCoords(coords, outOfDeadzone, pivotInstance) {
    global ANALOG_STICK_MAX, global FORCE_FTILT
    global TIMELIMIT_TAPSHUTOFF, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_PIVOTTILT_YDASH
    global P_RIGHTLEFT, global P_LEFTRIGHT, global xComp, global yComp, global currentTimeMS
    aX := coords[xComp], aY := coords[yComp]

    upYDeadzone := getCurrentOutOfDeadzoneInfo_up(aY, outOfDeadzone.up.saved, outOfDeadzone.up.queue)
    downYDeadzone := getCurrentOutOfDeadzoneInfo_down(aY, outOfDeadzone.down.saved, outOfDeadzone.down.queue)

    if (currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT) {
        /*  if upYDeadzone.out and the player has not shut off tap jump WITH actions done before completing
            the pivot (such as upY dashes and downY dashes)
        */
        if (upYDeadzone.out and (currentTimeMS - upYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF
            or upYDeadzone.timestamp >= pivotInstance.timestamp)) {
            if (Abs(aX) > aY) {
                /*  //Force all upward angles to a minimum of 45deg away from the horizontal
                    //to prevent pivot uftilt and ensure tap jump
                */
                return bringToCircleBorder([aX > 0 ? 128 : -128, 128]) ; [+/-128, 128]: 45 degrees
            } else {
                return bringToCircleBorder(coords)
            }
        }
        ; if the player hasn't shut off tap downsmash
        else if (downYDeadzone.out and currentTimeMS - downYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF) {
            return bringToCircleBorder(coords)
        }
        ; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes
        else if (upYDeadzone.out and upYDeadzone.timestamp < pivotInstance.timestamp
            and currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
            /*  if P_RIGHTLEFT then negative X
                if P_LEFTRIGHT then positive X
                apparently CarVac uses the opposite x directions for the ftilt.
                what does the proposal team mean when saying pressing A too early as a failure state?
            */
            return [pivotInstance.did == P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT, FORCE_FTILT]
        }
        ; if the player shut off tap downsmash, by pivoting with downY dashes
        else if (downYDeadzone.out and downYDeadzone.timestamp < pivotInstance.timestamp
            and currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
            return [pivotInstance.did == P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT, -FORCE_FTILT]
        }
    }
    return false ; if we reach this, conditions for applying nerfs weren't fulfilled
}