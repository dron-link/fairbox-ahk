#Requires AutoHotkey v1.1

getCurrentPivotInfo(didPivotNow, pivotSaved, pivotQueue) {
    global currentTimeMS

    if (didPivotNow == pivotSaved.did) {
        return pivotSaved
    } else if IsObject(pivotQueue[didPivotNow]) {
        return pivotQueue[didPivotNow] 
    } ; else
    return new pivotInfo(didPivotNow, currentTimeMS)
}

