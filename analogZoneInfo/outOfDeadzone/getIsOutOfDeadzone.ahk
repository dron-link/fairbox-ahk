#Requires AutoHotkey v1.1

getIsOutOfDeadzone_up(aY) {
    global ANALOG_DEAD_MAX
    return (ANALOG_DEAD_MAX < aY)
}

getIsOutOfDeadzone_down(aY) {
    global ANALOG_DEAD_MIN
    return (aY < ANALOG_DEAD_MIN)
}
