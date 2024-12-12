#Requires AutoHotkey v1

pivotTimingCheck(dashZoneHist, currentDashTimestamp) {
    global TIMELIMIT_HALFFRAME, global TIMELIMIT_FRAME, global TIMESTALE_PIVOT_INPUTSEQUENCE
    ; early Returns ahead.

    ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
    if (currentDashTimestamp - dashZoneHist[2].timestamp > TIMESTALE_PIVOT_INPUTSEQUENCE) {
        return false
    }

    ; true if the following sequence is stale:  NOW center  1 oppositeCardinal  2 center  3 cardinal
    if (!dashZoneHist[2].zone 
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