#Requires AutoHotkey v1.1

getDashZoneOf(aX, aY) {
    global ANALOG_DASH_LEFT, global ANALOG_DASH_RIGHT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    if (aX <= ANALOG_DASH_LEFT) {
        return ZONE_L
    } else if (aX >= ANALOG_DASH_RIGHT) {
        return ZONE_R
    } else {
        return ZONE_CENTER
    }
}

getCurrentDashZoneInfo(aX, aY, dashZone) {
    global currentTimeMS

    currentZone := getDashZoneOf(aX, aY)
    if (currentZone == dashZone.saved.zone) {
        return dashZone.saved
    } else if IsObject(dashZone.queue[currentZone]) {
        return dashZone.queue[currentZone]
    } else {
        return new dashZoneHistoryEntry(currentZone, currentTimeMS, false)
    }
}

storeDashZoneInfoBeforeMultipressEnds(aX, aY, ByRef dashZone) {
    global currentTimeMS
    dashZoneOfOutput := getDashZoneOf(aX, aY)
    if (dashZoneOfOutput == dashZone.saved.zone) {
        dashZone.unsaved := dashZone.saved
    } else {
        if !IsObject(dashZone.queue[dashZoneOfOutput]) {
            dashZone.queue[dashZoneOfOutput] := new dashZoneHistoryEntry(dashZoneOfOutput, currentTimeMS, false)
        }
        dashZone.unsaved := dashZone.queue[dashZoneOfOutput]
    }
    return
}
