#Requires AutoHotkey v1.1

getUncrouchNerfedCoords(coords, uncrouchCompletionInfo) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MAX, global TIMELIMIT_DOWNUP
    global xComp, global yComp, global currentTimeMS
    ; early Returns ahead.

    if (currentTimeMS - uncrouchCompletionInfo.timestamp >= TIMELIMIT_DOWNUP
        or !uncrouchCompletionInfo.uncrouch) {
        return false ; No uncrouch, or all uncrouch nerfs expired.
    }

    aX := coords[xComp], aY := coords[yComp]
    if (getIsOutOfDeadzone_up(aY) and Abs(aX) <= ANALOG_DEAD_MAX) {
        return [0, ANALOG_STICK_MAX]
    }
    ; else
    return false ; if we reach this, no conditions for applying nerfs were fulfilled
}