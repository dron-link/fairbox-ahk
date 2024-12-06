#Requires AutoHotkey v1.1

getUncrouchDid(crouchZoneSavedZone, crouchZoneNow) {
    global U_YES
    if (!crouchZoneNow and crouchZoneSavedZone) {
        return U_YES
    } ; else
    return false
}
