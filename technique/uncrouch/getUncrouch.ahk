#Requires AutoHotkey v1.1

getUncrouchDid(aX, aY, crouchZone) {
    global U_YES
    if (!getCrouchZoneOf(aX, aY) and crouchZone.saved.zone) {
        return U_YES
    } else {
        return false
    }
}

getUncrouchLockoutNerfedCoords(coords, uncrouch, uncrouchInstance) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MAX, global TIMELIMIT_DOWNUP
    global xComp, global yComp, global currentTimeMS
    aX := coords[xComp], aY := coords[yComp]

    if (currentTimeMS - uncrouchInstance.timestamp < TIMELIMIT_DOWNUP and getIsOutOfDeadzone_up(aY)
        and Abs(aX) <= ANALOG_DEAD_MAX) {
        return [0, ANALOG_STICK_MAX]
    }
    return false ; if we reach this, conditions for applying nerfs weren't fulfilled
}

getCurrentUncrouchInfo(aX, aY, didUncrouchNow, uncrouch) {
    global currentTimeMS

    if (didUncrouchNow == uncrouch.saved.did) {
        return uncrouch.saved
    } else if IsObject(uncrouch.queue[didUncrouchNow]) {
        return uncrouch.queue[didUncrouchNow]
    } else {
        return new uncrouchInfo(didUncrouchNow, currentTimeMS)
    }
}