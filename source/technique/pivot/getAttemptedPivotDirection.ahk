#Requires AutoHotkey v1.1

getAttemptedPivotDirection(dashZoneHist, currentZone) {
    global ZONE_L, global ZONE_R, global P_RIGHTLEFT, global P_LEFTRIGHT
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
    if !currentZone {
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