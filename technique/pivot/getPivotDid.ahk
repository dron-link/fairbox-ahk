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