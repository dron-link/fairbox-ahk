#Requires AutoHotkey v1.1

getDidPivot(aX, aY, dashZone) {
    currentDashZoneInfo := getCurrentDashZoneInfo(aX, aY, dashZone)

    direction := getAttemptedPivotDirection(currentDashZoneInfo.zone, dashZone.hist)
    if direction {
        return pivotTimingCheck(currentDashZoneInfo.timestamp, dashZone.hist)? direction : false
    }

    return false
}

getAttemptedPivotDirection(currentZone, dashZoneHist) {
    global ZONE_CENTER, global ZONE_L, global ZONE_R, global P_RIGHTLEFT, global P_LEFTRIGHT
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
        if (dashZoneHist[1].zone == ZONE_L and (dashZoneHist[2].zone == ZONE_R or dashZoneHist[3].zone == ZONE_R)) {
            return P_RIGHTLEFT
        }
        else if (dashZoneHist[1].zone == ZONE_R and (dashZoneHist[2].zone == ZONE_L or dashZoneHist[3].zone == ZONE_L)) {
            return P_LEFTRIGHT
        }
    }
    return false
}

pivotTimingCheck(currentDashTimestamp, dashZoneHist) {
    global ZONE_CENTER, global TIMELIMIT_HALFFRAME, global TIMELIMIT_FRAME

    latestDashDuration := currentDashTimestamp - dashZoneHist[1].timestamp

    ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
    if dashZoneHist[2].stale {
        return false
    }
    ; true if the following sequence is stale:  NOW center  1 oppositeCardinal  2 center  3 cardinal
    else if (dashZoneHist[2].zone == ZONE_CENTER and dashZoneHist[3].stale) {
        return false
    }
    /*  has the player only held the latest dash for around 1
        frame in duration? that's necessary for pivoting
    */
    else if (latestDashDuration < TIMELIMIT_HALFFRAME or TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME < latestDashDuration) {
        ; //less than 50% chance it was a successful pivot
        return false
    }

    return TRUE
}