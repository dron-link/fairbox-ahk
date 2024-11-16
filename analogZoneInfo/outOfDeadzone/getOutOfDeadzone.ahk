#Requires AutoHotkey v1.1

getCurrentOutOfDeadzoneInfo_up(aY, upObject) {
    global currentTimeMS

    deadzoneUpStatus := getIsOutOfDeadzone_up(aY)
    if (deadzoneUpStatus == upObject.saved.out) {
        return upObject.saved
    } else if IsObject(upObject.queue[deadzoneUpStatus]) {
        return upObject.queue[deadzoneUpStatus]
    } else {
        return new outOfDeadzoneInfo(deadzoneUpStatus, currentTimeMS)
    }
}

getCurrentOutOfDeadzoneInfo_down(aY, downObject) {
    global currentTimeMS

    deadzoneDownStatus := getIsOutOfDeadzone_down(aY)
    if (deadzoneDownStatus == downObject.saved.out) {
        return downObject.saved
    } else if IsObject(downObject.queue[deadzoneDownStatus]) {
        return downObject.queue[deadzoneDownStatus]
    } else {
        return new outOfDeadzoneInfo(deadzoneDownStatus, currentTimeMS)
    }
}

getIsOutOfDeadzone_up(aY) {
    global ANALOG_DEAD_MAX
    return (ANALOG_DEAD_MAX < aY)
}

getIsOutOfDeadzone_down(aY) {
    global ANALOG_DEAD_MIN
    return (aY < ANALOG_DEAD_MIN)
}