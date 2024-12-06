#Requires AutoHotkey v1.1


getIsInCrouchRange(aY) {
    global ANALOG_CROUCH
    ; early Returns ahead.
    return (aY <= ANALOG_CROUCH)
}