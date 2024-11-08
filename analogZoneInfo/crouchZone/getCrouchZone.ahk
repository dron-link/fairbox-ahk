#Requires AutoHotkey v1.1

getCrouchZoneOf(aX, aY) {
    global ANALOG_CROUCH, global ZONE_D, global ZONE_CENTER
    if (aY <= ANALOG_CROUCH) {
        return ZONE_D
    } else {
        return ZONE_CENTER
    }
}