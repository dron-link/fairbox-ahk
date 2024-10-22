#Requires AutoHotkey v1.1

class outOfDeadzoneInfo {
    __New(boolIs, timestamp) {
        this.is := boolIs
        this.timestamp := timestamp
    }
}

class leftstickOutOfDeadzoneBase {

    class up {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        queued := new outOfDeadzoneInfo(false, -1000)
        saved := new outOfDeadzoneInfo(false, -1000)
        is(aY) {
            global ANALOG_DEAD_MAX
            return (aY > ANALOG_DEAD_MAX)
        }
    }
    
    class down {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        queued := new outOfDeadzoneInfo(false, -1000)
        saved := new outOfDeadzoneInfo(false, -1000)
        is(aY) {
            global ANALOG_DEAD_MIN
            return (aY < ANALOG_DEAD_MIN)
        }
    }    
}

saveOutOfDeadzoneHistory(ByRef outOfDeadzone, latestMultipressBeginningTimestamp) {
    global TIMELIMIT_SIMULTANEOUS
    global currentTimeMS

    if (currentTimeMS - latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        ; new object so we can't modify it accidentally by manipulating up.unsaved and up.queued
        outOfDeadzone.up.saved := new outOfDeadzoneInfo(outOfDeadzone.up.unsaved.is, outOfDeadzone.up.unsaved.timestamp)
        ; clean queue
        outOfDeadzone.up.queued.is := false

        ; new object so we can't modify it accidentally by manipulating down.unsaved and down.queued
        outOfDeadzone.down.saved := new outOfDeadzoneInfo(outOfDeadzone.down.unsaved.is, outOfDeadzone.down.unsaved.timestamp)
        ; clean queue
        outOfDeadzone.down.queued.is := false
    }

    return
}

getCurrentOutOfDeadzoneInfo(analogAxisValue, deadzoneExitDirection) {
    global currentTimeMS

    if deadzoneExitDirection.saved.is {
        return new outOfDeadzoneInfo(deadzoneExitDirection.is(analogAxisValue), deadzoneExitDirection.saved.timestamp)
    } else if deadzoneExitDirection.queued.is {
        return new outOfDeadzoneInfo(deadzoneExitDirection.is(analogAxisValue), deadzoneExitDirection.queued.timestamp)
    } else {
        return new outOfDeadzoneInfo(deadzoneExitDirection.is(analogAxisValue), currentTimeMS)
    }
}