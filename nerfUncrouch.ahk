#Requires AutoHotkey v1.1

saveUncrouchHistory() {
    global

    /* we need to see if enough time has passed for the input to not be part of a multiple key single input. and that it is different
    from the last entry and so we need a new entry
    */
    if (currentTimeMS - crouchRangeTimestamp.simultaneous >= TIMELIMIT_SIMULTANEOUS) {
        if (crouchRange.unsaved != crouchRange.saved) { ; requiring this to be true is not useful but we focus on showing all the steps
            crouchRange.saved := crouchRange.unsaved
        }
        if uncrouched.unsaved {
            uncrouched.saved := uncrouched.unsaved
            uncrouchTimestamp.saved := uncrouchTimestamp.unsaved
            uncrouched.unsaved := false
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
    if (not crouchRangeOf(aY) and crouchRange.saved) {
        return U_YES
    } else {
        return U_NO
    }
}

uncrouchNerf(aX, aY) {
    global
    result := [aX, aY]

    uncrouchWasNerfed := true
    if (upY and Abs(aX) <= ANALOG_DEAD_MAX) {
        result[xComp] := 0
        result[yComp] := ANALOG_STICK_MAX
        uncrouchForced2FJump := false ; change to true to activate CarVac HayBox style timed nerf
        uncrouchForce2FJumpTimestamp := currentTimeMS
    }

    return result
}

rememberCrouchesNotSaved(aY) {
    global
    if (crouchRangeOf(aY) != crouchRange.unsaved) {
        crouchRange.unsaved := crouchRangeOf(aY)
        if (currentTimeMS - crouchRangeTimestamp.simultaneous >= TIMELIMIT_SIMULTANEOUS) {
            crouchRangeTimestamp.simultaneous := currentTimeMS
            analogHistory[currentIndexA].simultaneousFinish |= FINAL_CROUCHRANGE
        }
    }
    return
}
