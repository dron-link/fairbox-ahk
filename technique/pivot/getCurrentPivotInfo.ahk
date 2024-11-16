#Requires AutoHotkey v1.1

getCurrentPivotInfo(didPivotNow, pivot) {
    global currentTimeMS

    if (didPivotNow == pivot.saved.did) {
        return pivot.saved
    } else if IsObject(pivot.queue[didPivotNow]) {
        return pivot.queue[didPivotNow] 
    } ; else
    return new pivotInfo(didPivotNow, currentTimeMS)
}

