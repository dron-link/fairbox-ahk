#Requires AutoHotkey v1

getIsInCrouchRange(aY) {
    global ANALOG_CROUCH
    return (aY <= ANALOG_CROUCH)
}