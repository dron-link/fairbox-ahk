#Requires AutoHotkey v1.1

getPivotDid(dashZoneHist, currentDashZoneZone, currentDashTimestamp) {
    ; early Returns ahead.
    direction := getAttemptedPivotDirection(dashZoneHist, currentDashZoneZone)
    if direction { 
        ; if the timing is correct, we confirm that there was a pivot in the direction
        return pivotTimingCheck(dashZoneHist, currentDashTimestamp)? direction : false
    } 
    ; else
    return false ; the order of inputs is incorrect
}

getAttemptedPivotDirection(dashZoneHist, currentZone) {
    global ZONE_CENTER, global ZONE_L, global ZONE_R, global P_RIGHTLEFT, global P_LEFTRIGHT
    ; early Returns ahead.

    /*  ignoring timing, has the player inputted the correct sequence?
        empty pivot inputs:
        --- past --> current
        3---2---1---aX        means:      notes:
            R   L   N       p rightleft
        R   -   L   N       p rightleft   (it's R N L N because there can't be R R or L L in history)
            L   R   N       p leftright
        L   -   R   N       p leftright   (L N R N)
        (in this comment, N means center)
    */
    if (currentZone == ZONE_CENTER) {
        if (dashZoneHist[1].zone == ZONE_L 
            and (dashZoneHist[2].zone == ZONE_R or dashZoneHist[3].zone == ZONE_R)) {
            return P_RIGHTLEFT
        }
        if (dashZoneHist[1].zone == ZONE_R 
            and (dashZoneHist[2].zone == ZONE_L or dashZoneHist[3].zone == ZONE_L)) {
            return P_LEFTRIGHT
        }
    }
    ; else
    return false ; the sequence is incorrect
}

pivotTimingCheck(dashZoneHist, currentDashTimestamp) {
    global ZONE_CENTER
    global TIMELIMIT_HALFFRAME, global TIMELIMIT_FRAME, global TIMESTALE_PIVOT_INPUTSEQUENCE
    ; early Returns ahead.

    ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
    if (currentDashTimestamp - dashZoneHist[2].timestamp > TIMESTALE_PIVOT_INPUTSEQUENCE) {
        return false
    }

    ; true if the following sequence is stale:  NOW center  1 oppositeCardinal  2 center  3 cardinal
    if (dashZoneHist[2].zone == ZONE_CENTER 
        and currentDashTimestamp - dashZoneHist[3].timestamp > TIMESTALE_PIVOT_INPUTSEQUENCE) {
        return false
    } 

    /*  has the player only held the latest dash for around 1
        frame in duration? that's necessary for pivoting
    */
    latestDashDuration := currentDashTimestamp - dashZoneHist[1].timestamp
    if (latestDashDuration < TIMELIMIT_HALFFRAME or TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME < latestDashDuration) {
        return false ; //less than 50% chance it was a successful pivot
    } 
    ; else
    return TRUE
}