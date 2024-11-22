#Requires AutoHotkey v1.1


getDashZoneOf(aX) {
    global ANALOG_DASH_LEFT, global ANALOG_DASH_RIGHT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    ; early Returns ahead.
    if (aX <= ANALOG_DASH_LEFT) {
        return ZONE_L
    }
    if (ANALOG_DASH_RIGHT <= aX) {
        return ZONE_R
    } 
    ; else
    return ZONE_CENTER
}


getCurrentDashZoneInfo(dashZoneSaved, dashZoneQueue, currentZone) {
    global currentTimeMS
    ; early Returns ahead.

    if (currentZone == dashZoneSaved.zone) {
        return dashZoneSaved
    } 
    if IsObject(dashZoneQueue[currentZone]) {
        return dashZoneQueue[currentZone]
    } 
    ; else
    return new dashZoneHistoryEntry(currentZone, currentTimeMS, false)
}