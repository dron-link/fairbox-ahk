#Requires AutoHotkey v1.1

getDashZoneOf(aX) {
    global ANALOG_DASH_LEFT, global ANALOG_DASH_RIGHT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    if (aX <= ANALOG_DASH_LEFT) {
        return ZONE_L
    } else if (ANALOG_DASH_RIGHT <= aX) {
        return ZONE_R
    } ; else
    return ZONE_CENTER
}

getCurrentDashZoneInfo(aX, dashZoneSaved, dashZoneQueue) {
    global currentTimeMS

    currentZone := getDashZoneOf(aX)
    if (currentZone == dashZoneSaved.zone) {
        return dashZoneSaved
    } else if IsObject(dashZoneQueue[currentZone]) {
        return dashZoneQueue[currentZone]
    } ; else
    return new dashZoneHistoryEntry(currentZone, currentTimeMS, false)
}