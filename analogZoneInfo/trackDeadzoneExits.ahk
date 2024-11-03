#Requires AutoHotkey v1.1

class outOfDeadzoneInfo {
    __New(boolOut, timestamp) {
        this.out := boolOut
        this.timestamp := timestamp
    }
}

class leftstickOutOfDeadzoneBase {
    class upBase {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        queue := {}
        saved := new outOfDeadzoneInfo(false, -1000)
        isOut(aY) {
            global ANALOG_DEAD_MAX
            return (aY > ANALOG_DEAD_MAX)
        }
    }
    
    class downBase {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        queue := {}
        saved := new outOfDeadzoneInfo(false, -1000)
        isOut(aY) {
            global ANALOG_DEAD_MIN
            return (aY < ANALOG_DEAD_MIN)
        }
    }    

    __New() {
        this.up := new this.upBase
        this.down := new this.downBase
    }

    saveHistory() {
        this.up.saved := this.up.unsaved, this.up.queue := {}
        this.down.saved := this.down.unsaved, this.down.queue := {}
        return
    }

    storeInfoBeforeMultipressEnds(aY) {
        return storeOutOfDeadzoneInfoBeforeMultipressEnds(aY, this)
    }
}

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