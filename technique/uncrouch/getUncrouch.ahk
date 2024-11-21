#Requires AutoHotkey v1.1

getUncrouchDid(aY, crouchZoneSavedZone) {
    global U_YES
    if (!getCrouchZoneOf(aY) and crouchZoneSavedZone) {
        return U_YES
    } ; else
    return false
}

getUncrouchLockoutNerfedCoords(coords, uncrouchTimestamp) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MAX, global TIMELIMIT_DOWNUP
    global xComp, global yComp, global currentTimeMS
    aX := coords[xComp], aY := coords[yComp]

    if (currentTimeMS - uncrouchTimestamp < TIMELIMIT_DOWNUP and getIsOutOfDeadzone_up(aY)
        and Abs(aX) <= ANALOG_DEAD_MAX) {
        return [0, ANALOG_STICK_MAX]
    }
    return false ; if we reach this, conditions for applying nerfs weren't fulfilled
}

getCurrentUncrouchInfo(didUncrouchNow, uncrouchSaved, uncrouchQueue) {
    global currentTimeMS

    if (didUncrouchNow == uncrouchSaved.did) {
        return uncrouchSaved
    } else if IsObject(uncrouchQueue[didUncrouchNow]) {
        return uncrouchQueue[didUncrouchNow]
    } else {
        return new uncrouchInfo(didUncrouchNow, currentTimeMS)
    }
}