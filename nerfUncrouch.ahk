#Requires AutoHotkey v1.1

saveUncrouchHistory() {
    global

    /* we need to see if enough time has passed for the input to not be part of a multiple key single input. and that it is different
    from the last entry and so we need a new entry
    */
    if (currentTimeMS - oldestUnsavedCrouchZoneTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        if (crouchZone.unsaved.zone != crouchZone.saved.zone) { ; requiring this to be true is not useful but we focus on showing all the steps
            crouchZone.saved.zone := crouchZone.unsaved.zone
        }
        if uncrouch.unsaved.did {
            uncrouch.saved.did := uncrouch.unsaved.did
            uncrouch.saved.timestamp := uncrouch.unsaved.timestamp
            uncrouch.unsaved.did := false
        }
    }
    return
}

crouchRangeOf(aY) {
    global ANALOG_CROUCH
    if (aY <= ANALOG_CROUCH) {
        return true
    } else {
        return false
    }
}

detectUncrouch(aY) {
    global
    if (not crouchRangeOf(aY) and crouchZone.saved.zone) {
        return U_YES
    } else {
        return U_NO
    }
}

uncrouchNerf(aX, aY) {
    global
    result := [aX, aY]

    nerfedUncrouchWasCalc := true
    if (upY and Abs(aX) <= ANALOG_DEAD_MAX) {
        result[xComp] := 0
        result[yComp] := ANALOG_STICK_MAX
        uncrouch2FJump.force := false ; change to true to activate CarVac HayBox style timed nerf
        uncrouch2FJump.timestamp := currentTimeMS
    }

    return result
}

rememberCrouchesNotSaved(aY) {
    global
    if (crouchRangeOf(aY) != crouchZone.unsaved.zone) {
        crouchZone.unsaved.zone := crouchRangeOf(aY)
        if (currentTimeMS - oldestUnsavedCrouchZoneTimestamp >= TIMELIMIT_SIMULTANEOUS) {
            oldestUnsavedCrouchZoneTimestamp := currentTimeMS
            analogHistory[currentIndexA].simultaneousFinish |= FINAL_CROUCHRANGE
        }
    }
    return
}
