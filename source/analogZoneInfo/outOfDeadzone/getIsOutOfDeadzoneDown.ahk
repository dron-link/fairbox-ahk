#Requires AutoHotkey v1

getIsOutOfDeadzoneDown(aY) {
    global ANALOG_DEAD_MIN
    return (aY < ANALOG_DEAD_MIN)
}