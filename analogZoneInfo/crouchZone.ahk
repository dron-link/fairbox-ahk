#Requires AutoHotkey v1.1

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
