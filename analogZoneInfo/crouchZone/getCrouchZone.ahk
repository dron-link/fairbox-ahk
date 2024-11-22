#Requires AutoHotkey v1.1


getCrouchZoneOf(aY) {
    global ANALOG_CROUCH, global ZONE_D, global ZONE_CENTER
    ; early Returns ahead.
    if (aY <= ANALOG_CROUCH) {
        return ZONE_D
    } ; else
    return ZONE_CENTER
}