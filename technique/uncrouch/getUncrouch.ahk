#Requires AutoHotkey v1.1

getUncrouchDid(aX, aY, crouchZone) {
    global U_YES
    if (!getCrouchZoneOf(aX, aY) and crouchZone.saved.zone) {
        return U_YES
    } else {
        return false
    }
}

getUncrouchLockoutNerfedCoords(aX, aY, uncrouchInstance, uncrouch) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MAX, global TIMELIMIT_DOWNUP, global currentTimeMS

    upYDeadzone := getCurrentOutOfDeadzoneInfo(aY, uncrouch.outOfDeadzone.up)

    if (currentTimeMS - uncrouchInstance.timestamp < TIMELIMIT_DOWNUP and upYDeadzone.out and Abs(aX) <= ANALOG_DEAD_MAX) {
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