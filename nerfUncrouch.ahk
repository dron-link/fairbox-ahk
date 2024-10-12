#Requires AutoHotkey v1.1

class crouchZoneHistoryEntry {
    __New(zone, timestamp) {
        this.zone := zone
        this.timestamp := timestamp
    }
}

class crouchZoneObjectTemplate {
    string := "crouchZone"
    lastDelivered := new crouchZoneHistoryEntry(0, false)
    saved := new crouchZoneHistoryEntry(0, false)
    oldestQueueTimestamp := -1000

    zoneOf(aX, aY) {
        global ANALOG_CROUCH
        global ZONE_D
        global STOOD_UP
        if (aY <= ANALOG_CROUCH) {
            return ZONE_D
        } else {
            return STOOD_UP
        }
    }
}

class uncrouchInfo {
    __New(did, timestamp) {
        this.did := did
        this.timestamp := timestamp
    }
}

class uncrouchObjectTemplate {
    string:="uncrouch"

    fromDetector := new uncrouchInfo(false, -1000)
    queued := new uncrouchInfo(false, -1000)
    saved := new uncrouchInfo(false, -1000)

    wasLookedFor := false
    nerfWasCalc := false
    nerfedCoords := [0, 0]

    jump2F := {force: false, timestamp: -1000}

    detect(aX, aY, crouchZone) {
        global U_YES
        if (not crouchZone.zoneOf(aX, aY) and crouchZone.saved.zone) {
            return U_YES
        } else {
            return false
        }
    }

    nerf(aX, aY, bufferStage) {
        global
        this.nerfWasCalc := true
        if (upY and Abs(aX) <= ANALOG_DEAD_MAX) {
            this.jump2F.force := false ; change to true to activate CarVac HayBox style timed nerf
            this.jump2F.timestamp := currentTimeMS
            return [0, ANALOG_STICK_MAX]
        } else {
            return [aX, aY]
        }
    }

}


saveUncrouchHistory(ByRef crouchZone, ByRef uncrouch) {
    global

    /* we need to see if enough time has passed for the input to not be part of a multiple key single input. and that it is different
    from the last entry and so we need a new entry
    */
    if (currentTimeMS - crouchZone.oldestQueueTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        if (crouchZone.lastDelivered.zone != crouchZone.saved.zone) {
            crouchZone.saved := crouchZone.lastDelivered
        }
        if uncrouch.queued.did {
            uncrouch.saved := uncrouch.queued
            uncrouch.queued := new uncrouchInfo(false, 0)
        }
    }
    return
}

rememberCrouchZonesNotSaved(aY, ByRef crouchZone) {
    global
    
    if (crouchZone.zoneOf("", aY) != crouchZone.lastDelivered.zone) {
        crouchZone.lastDelivered := new crouchZoneHistoryEntry(crouchZone.zoneOf("", aY), currentTimeMS)
        ; i can move this to teh beginning of limitOutputs to save lines and if it makes sense in there
        if (currentTimeMS - crouchZone.oldestQueueTimestamp >= TIMELIMIT_SIMULTANEOUS) {
            crouchZone.oldestQueueTimestamp := currentTimeMS
            analogHistory[1].simultaneousFinish |= FINAL_CROUCHRANGE
        }
    }
    return
}
