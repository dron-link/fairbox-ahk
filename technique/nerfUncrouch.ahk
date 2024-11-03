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
        this.queue := {}
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
    saved := new uncrouchInfo(false, -1000)
    lockout := new uncrouchInfo(false, -1000)

    wasNerfed := false
    nerfedCoords := ""

    saveHistory() {
        if (this.unsaved.did and this.unsaved.did != this.saved.did) {
            this.lockout := this.unsaved
        }
        this.saved := this.unsaved, this.queue := {}
        return
    }

    lockoutExpiryCheck() {
        global TIMELIMIT_DOWNUP, global currentTimeMS
        if (this.lockout.did and currentTimeMS - this.lockout.timestamp >= TIMELIMIT_DOWNUP) {
            this.lockout := new uncrouchInfo(false, currentTimeMS)
        }
        return
    }

    detect(aX, aY, crouchZone) {
        return detectUncrouch(aX, aY, crouchZone)
    }
    nerfSearch(aX, aY, crouchZone) {
        return nerfBasedOnHistory(aX, aY, crouchZone, uncrouchInfo, this)
    }
    generateNerfedCoords(aX, aY, uncrouchInstance) {
        this.nerfedCoords := getUncrouchLockoutNerfedCoords(aX, aY, uncrouchInstance, this)
        return
    }
    getCurrentInfo(aX, aY, crouchZone) {
        return getCurrentUncrouchInfo(aX, aY, detectUncrouch(aX, aY, crouchZone), this)
    }
    storeInfoBeforeMultipressEnds(aX, aY, crouchZone) {
        return storeUncrouchesBeforeMultipressEnds(aX, aY, detectUncrouch(aX, aY, crouchZone), this)
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

storeUncrouchesBeforeMultipressEnds(aX, aY, outputDidUncrouch, ByRef uncrouch) {
    global currentTimeMS

    if (outputDidUncrouch == uncrouch.saved.did) {
        uncrouch.unsaved := uncrouch.saved
    } else {
        if !IsObject(uncrouch.queue[outputDidUncrouch]) {
            uncrouch.queue[outputDidUncrouch] := new uncrouchInfo(outputDidUncrouch, currentTimeMS)
        }
        uncrouch.unsaved := uncrouch.queue[outputDidUncrouch]
    }

    return
}
