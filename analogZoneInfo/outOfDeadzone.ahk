#Requires AutoHotkey v1.1

getCurrentOutOfDeadzoneInfo(analogAxisValue, outOfDeadzoneDirection) {
    global currentTimeMS

    deadzoneStatus := outOfDeadzoneDirection.isOut(analogAxisValue)
    if (deadzoneStatus == outOfDeadzoneDirection.saved.out) {
        return outOfDeadzoneDirection.saved
    } else if IsObject(outOfDeadzoneDirection.queue[deadZoneStatus]) {
        return outOfDeadzoneDirection.queue[deadZoneStatus]
    } else {
        return new outOfDeadzoneInfo(deadzoneStatus, currentTimeMS)
    }
}

storeOutOfDeadzoneInfoBeforeMultipressEnds(aY, ByRef outOfDeadzone) {
    global currentTimeMS

    deadzoneUpStatus := outOfDeadzone.up.isOut(aY)
    if (deadzoneUpStatus == outOfDeadzone.up.saved.out) {
        outOfDeadzone.up.unsaved := outOfDeadzone.up.saved
    } else {
        if !IsObject(outOfDeadzone.up.queue[deadzoneUpStatus]) {
            outOfDeadzone.up.queue[deadzoneUpStatus] := new outOfDeadzoneInfo(deadzoneUpStatus, currentTimeMS)
        }
        outOfDeadzone.up.unsaved := outOfDeadzone.up.queue[deadzoneUpStatus]
    }

    deadzoneDownStatus := outOfDeadzone.down.isOut(aY)
    if (deadzoneDownStatus == outOfDeadzone.down.saved.out) {
        outOfDeadzone.down.unsaved := outOfDeadzone.down.saved
    } else {
        if !IsObject(outOfDeadzone.down.queue[deadzoneDownStatus]) {
            outOfDeadzone.down.queue[deadzoneDownStatus] := new outOfDeadzoneInfo(deadzoneDownStatus, currentTimeMS)
        }
        outOfDeadzone.down.unsaved := outOfDeadzone.down.queue[deadzoneDownStatus]
    }

    return
}