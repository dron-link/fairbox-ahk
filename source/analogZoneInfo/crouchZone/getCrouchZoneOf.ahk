#Requires AutoHotkey v1.1


getCrouchZoneOf(aY) {
    global ANALOG_CROUCH, global ZONE_D
    ; early Returns ahead.
    if (aY <= ANALOG_CROUCH) {
        return ZONE_D
    } ; else
    return 0
}