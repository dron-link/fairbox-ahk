#Requires AutoHotkey v1.1

class crouchZoneHistoryEntry {
    __New(zone, timestamp) {
        this.zone := zone
        this.timestamp := timestamp
    }
}

class baseCrouchZone {
    string := "crouchZone"

    unsaved := new crouchZoneHistoryEntry(false, -1000)
    queue := {}
    saved := new crouchZoneHistoryEntry(false, -1000)
    saveHistory() {
        this.saved := this.unsaved
        this.queued := {}
        return
    }
    zoneOf(aX, aY) {
        return getCrouchZoneOf(aX, aY)
    }
    storeInfoBeforeMultipressEnds(aX, aY) {
        return storeCrouchZoneInfoBeforeMultipressEnds(aX, aY, this)
    }

}

getCrouchZoneOf(aX, aY) {
    global ANALOG_CROUCH, global ZONE_D, global ZONE_CENTER
    if (aY <= ANALOG_CROUCH) {
        return ZONE_D
    } else {
        return ZONE_CENTER
    }
}

storeCrouchZoneInfoBeforeMultipressEnds(aX, aY, ByRef crouchZone) {
    global currentTimeMS
    crouchZoneOfOutput := getCrouchZoneOf(aX, aY)
    if (crouchZoneOfOutput == crouchZone.saved.zone) {
        crouchZone.unsaved := crouchZone.saved
    } else {
        if !IsObject(crouchZone.queue[crouchZoneOfOutput]) {
            crouchZone.queue[crouchZoneOfOutput] := new crouchZoneHistoryEntry(crouchZoneOfOutput, currentTimeMS)
        }
        crouchZone.unsaved := crouchZone.queue[crouchZoneOfOutput]
    }
    return
}

class uncrouchInfo extends techniqueClassThatHasTimingLockouts {
}

class baseUncrouch {
    string:="uncrouch"

    unsaved := new uncrouchInfo(false, -1000)
    queue := {}
    queued := new uncrouchInfo(false, -1000)
    saved := new uncrouchInfo(false, -1000)
    lockout := new uncrouchInfo(false, -1000)

    wasNerfed := false
    nerfedCoords := ""

    jump2F := {force: false, timestamp: -1000}

    detect(aX, aY, crouchZone) {
        return detectUncrouch(aX, aY, crouchZone)
    }

    generateNerfedCoords(aX, aY, uncrouchInstance) {
        this.nerfedCoords := getUncrouchLockoutNerfedCoords(aX, aY, uncrouchInstance, this)
        return
    }
}

detectUncrouch(aX, aY, crouchZone) {
    global U_YES
    if (!getCrouchZoneOf(aX, aY) and crouchZone.saved.zone) {
        return U_YES
    } else {
        return false
    }
}

getUncrouchLockoutNerfedCoords(aX, aY, uncrouchInstance, ByRef uncrouch) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MAX, global TIMELIMIT_DOWNUP, global currentTimeMS

    upYDeadzone := getCurrentOutOfDeadzoneInfo(aY, uncrouch.outOfDeadzone.up)

    if (currentTimeMS - uncrouchInstance.timestamp < TIMELIMIT_DOWNUP and upYDeadzone.out and Abs(aX) <= ANALOG_DEAD_MAX) {
        uncrouch.wasNerfed := true
        return [0, ANALOG_STICK_MAX]
    }
    return
}


saveUncrouchHistory(ByRef crouchZone, ByRef uncrouch, latestMultipressBeginningTimestamp) {
    global TIMELIMIT_SIMULTANEOUS, global currentTimeMS

    ; set lingering uncrouch as false
    if uncrouch.saved.did {
        uncrouch.saved.did := currentTimeMS - uncrouch.saved.timestamp < 1000 ? uncrouch.saved.did : false
    }
    /*
    we need to see if enough time has passed for the input to not be part of a multiple keys
    single input, and that it is different
    from the last entry and so we need a new entry
    */
    if (currentTimeMS - latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        if uncrouch.unsaved.did {
            uncrouch.saved := new uncrouchInfo(uncrouch.unsaved.did, uncrouch.unsaved.timestamp)
            uncrouch.unsaved.did := false, uncrouch.queued.did := false
        }
    }
    return
}

storeUncrouchesBeforeMultipressEnds(output, ByRef crouchZone, ByRef uncrouch) {
    global currentTimeMS

    ; handles the case of nerfing the uncrouch input into a crouch, so it damages the successful uncrouch input
    uncrouch.unsaved.did := uncrouch.detect(output.limited.x, output.limited.y, crouchZone)
    ; stores the first uncrouch detected within the multipress window
    if (uncrouch.unsaved.did and !uncrouch.queued.did) {
        ; new object so that modifying unsaved.did doesn't modify queued.did
        uncrouch.queued.did := new uncrouchInfo(uncrouch.unsaved.did, uncrouch.unsaved.timestamp)
    }

    return
}
