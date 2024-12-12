#Requires AutoHotkey v1

getUncrouchNerfCondition(aX, aY, relevantCrouchRangeInfo) {
    global ANALOG_DEAD_MAX, global TIMELIMIT_DOWNUP
    global xComp, global yComp, global currentTimeMS

    ; guard clause
    if (currentTimeMS - relevantCrouchRangeInfo.timestamp >= TIMELIMIT_DOWNUP
        or !relevantCrouchRangeInfo.uncrouch) {
        return false ; No uncrouch, or all uncrouch nerfs expired.
    }

    ; else, if we are within the nerf time window:
    ; is the analog stick in the forbidden range?
    if (getIsOutOfDeadzoneUp(aY) and Abs(aX) <= ANALOG_DEAD_MAX) {
        return true
    } else {
        return false
    }
}