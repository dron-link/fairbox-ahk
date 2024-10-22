#Requires AutoHotkey v1.1

saveDeadzoneExitHistory(ByRef deadzoneExit, latestMultipressBeginningTimestamp) {
    global TIMELIMIT_SIMULTANEOUS
    global currentTimeMS

    if (currentTimeMS - latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        ; new object so we can't modify it accidentally by manipulating up.unsaved and up.queued
        deadzoneExit.up.saved := new deadzoneExitInfo(deadzoneExit.up.unsaved.did, deadzoneExit.up.unsaved.timestamp)
        ; clean queue
        deadzoneExit.up.queued.did := false

        ; new object so we can't modify it accidentally by manipulating down.unsaved and down.queued
        deadzoneExit.down.saved := new deadzoneExitInfo(deadzoneExit.down.unsaved.did, deadzoneExit.down.unsaved.timestamp)
        ; clean queue
        deadzoneExit.down.queued.did := false
    }

    return
}

getCurrentDeadzoneExitInfo(analogAxisValue, deadzoneExitDirection) {
    global currentTimeMS

    if deadzoneExitDirection.saved.did {
        return new deadzoneExitInfo(deadzoneExitDirection.is(analogAxisValue), deadzoneExitDirection.saved.timestamp)
    } else if deadzoneExitDirection.queued.did {
        return new deadzoneExitInfo(deadzoneExitDirection.is(analogAxisValue), deadzoneExitDirection.queued.timestamp)
    } else {
        return new deadzoneExitInfo(deadzoneExitDirection.is(analogAxisValue), currentTimeMS)
    }
}