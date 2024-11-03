#Requires AutoHotkey v1.1

detectPivot(aX, aY, dashZone) {
    global P_RIGHTLEFT, global P_LEFTRIGHT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    global TIMELIMIT_HALFFRAME, global TIMELIMIT_FRAME

    result := False
    pivotDebug := false ; if you want to test detectPivot() live, set this true
    pivotDiscarded := -1 ; for testing. -1 to avoid all switch-cases
    currentDashZone := getCurrentDashZoneInfo(aX, aY, dashZone)
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
    if (currentDashZone.zone == ZONE_CENTER) {
        if (dashZone.hist[1].zone == ZONE_L and (dashZone.hist[2].zone == ZONE_R or dashZone.hist[3].zone == ZONE_R)) {
            result := P_RIGHTLEFT
            pivotDiscarded := false
        }
        else if (dashZone.hist[1].zone == ZONE_R and (dashZone.hist[2].zone == ZONE_L or dashZone.hist[3].zone == ZONE_L)) {
            result := P_LEFTRIGHT
            pivotDiscarded := false
        }
    }

    if result { ; this is the code block for discarding pivot attempts
        pivotLength := currentDashZone.timestamp - dashZone.hist[1].timestamp ; ms, computes latest dash duration
        ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
        if dashZone.hist[2].stale {
            result := false
            if !pivotDiscarded {
                pivotDiscarded := 1
            }
        }
        ; true if the following sequence is stale:  aX center  1 oppositeCardinal  2 center  3 cardinal
        else if (dashZone.hist[2].zone == ZONE_CENTER and dashZone.hist[3].stale) {
            result := false
            if !pivotDiscarded {
                pivotDiscarded := 1
            }
        }
        /*  has the player only held the latest dash for around 1
            frame in duration? that's necessary for pivoting
        */
        else if (pivotLength < TIMELIMIT_HALFFRAME or pivotLength > TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME) {
            ; //less than 50% chance it was a successful pivot
            result := false
            if !pivotDiscarded {
                pivotDiscarded := 2
            }
        }
    } ; end of block for discarding pivot attempts
    
    if pivotDebug {
        pivotLiveDebugMessages(result, pivotDiscarded) ; over at testingTools.ahk
    }

    return result ; returns whether there was no pivot, or the direction of the pivot if there was
}