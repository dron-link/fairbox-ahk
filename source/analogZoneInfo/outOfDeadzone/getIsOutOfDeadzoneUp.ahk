#Requires AutoHotkey v1

getIsOutOfDeadzoneUp(aY) {
    global ANALOG_DEAD_MAX
    return (ANALOG_DEAD_MAX < aY)
}