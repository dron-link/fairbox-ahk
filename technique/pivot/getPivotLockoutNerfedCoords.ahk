#Requires AutoHotkey v1.1

getPivotLockoutNerfedCoords(aX, aY, pivotInstance, ByRef pivot) {
    global ANALOG_STICK_MAX, global FORCE_FTILT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    global TIMELIMIT_TAPSHUTOFF, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_PIVOTTILT_YDASH
    global P_RIGHTLEFT, global P_LEFTRIGHT, global xComp, global yComp, global currentTimeMS

    upYDeadzone := getCurrentOutOfDeadzoneInfo(aY, pivot.outOfDeadzone.up)
    downYDeadzone := getCurrentOutOfDeadzoneInfo(aY, pivot.outOfDeadzone.down)
    doTrimCoordinate := false

    if ((aX != 0 or aY != 0) and currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT) {
        maxDistanceFactor := 1.1 * ANALOG_STICK_MAX / sqrt(aX**2 + aY**2) ; 1.1 ensures shoot beyond circle

        /*  if upYDeadzone.out and the player has not shut off tap jump WITH actions done before completing
            the pivot (such as upY dashes and downY dashes)
        */
        if (upYDeadzone.out and (currentTimeMS - upYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF or upYDeadzone.timestamp >= pivotInstance.timestamp)) {
            pivot.wasNerfed := true
            if (Abs(aX) > aY) {
                /*  //Force all upward angles to a minimum of 45deg away from the horizontal
                    //to prevent pivot uftilt and ensure tap jump
                */
                return trimToCircle(aX > 0 ? 90 : -90, 90) ; params [90, 90] or [-90, 90]. is radius=127
            } else {
                return trimToCircle(aX * maxDistanceFactor, aY * maxDistanceFactor)
            }
        }
        ; if the player hasn't shut off tap downsmash
        else if (downYDeadzone.out and currentTimeMS - downYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF) {
            pivot.wasNerfed := true
            return trimToCircle(aX * maxDistanceFactor, aY * maxDistanceFactor)
        }
        ; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes
        else if (upYDeadzone.out and upYDeadzone.timestamp < pivotInstance.timestamp
            and currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
            pivot.wasNerfed := true
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
            pivot.wasNerfed := true
            return [pivotInstance.did == P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT     , -FORCE_FTILT]
        }
    }
    return
}