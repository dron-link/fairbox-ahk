#Requires AutoHotkey v1.1

getIsOutOfDeadzone_up(aY) {
    global ANALOG_DEAD_MAX
    return (ANALOG_DEAD_MAX < aY)
}

getIsOutOfDeadzone_down(aY) {
    global ANALOG_DEAD_MIN
    return (aY < ANALOG_DEAD_MIN)
}

getCurrentOutOfDeadzoneInfo_up(aY, upSaved, upQueue) {
    global currentTimeMS

    deadzoneUpStatus := getIsOutOfDeadzone_up(aY)
    if (deadzoneUpStatus == upSaved.out) {
        return upSaved
    } else if IsObject(upQueue[deadzoneUpStatus]) {
        return upQueue[deadzoneUpStatus]
    } ; else
    return new outOfDeadzoneInfo(deadzoneUpStatus, currentTimeMS)
}

getCurrentOutOfDeadzoneInfo_down(aY, downSaved, downQueue) {
    global currentTimeMS

    deadzoneDownStatus := getIsOutOfDeadzone_down(aY)
    if (deadzoneDownStatus == downSaved.out) {
        return downSaved
    } else if IsObject(downQueue[deadzoneDownStatus]) {
        return downQueue[deadzoneDownStatus]
    } ; else
    return new outOfDeadzoneInfo(deadzoneDownStatus, currentTimeMS)
}

