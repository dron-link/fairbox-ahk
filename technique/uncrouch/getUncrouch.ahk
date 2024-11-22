#Requires AutoHotkey v1.1

getUncrouchDid(crouchZoneSavedZone, crouchZoneNow) {
    global U_YES
    if (!crouchZoneNow and crouchZoneSavedZone) {
        return U_YES
    } ; else
    return false
}

getUncrouchLockoutNerfedCoords(coords, uncrouchTimestamp) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MAX, global TIMELIMIT_DOWNUP
    global xComp, global yComp, global currentTimeMS
    ; early Returns ahead.
    
    aX := coords[xComp], aY := coords[yComp]

    if (currentTimeMS - uncrouchTimestamp < TIMELIMIT_DOWNUP and getIsOutOfDeadzone_up(aY)
        and Abs(aX) <= ANALOG_DEAD_MAX) {
        return [0, ANALOG_STICK_MAX]
    }
    ; else
    return false ; if we reach this, no conditions for applying nerfs were fulfilled
}

getCurrentUncrouchInfo(uncrouchSaved, uncrouchQueue, didUncrouchNow) {
    global currentTimeMS
    ; early Returns ahead.

    if (didUncrouchNow == uncrouchSaved.did) {
        return uncrouchSaved
    }
    if IsObject(uncrouchQueue[didUncrouchNow]) {
        return uncrouchQueue[didUncrouchNow]
    } 
    ; else 
    return new uncrouchInfo(didUncrouchNow, currentTimeMS)
}