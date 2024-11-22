#Requires AutoHotkey v1.1


getCurrentPivotInfo(pivotSaved, pivotQueue, didPivotNow) {
    global currentTimeMS
    ; early Returns ahead.

    if (didPivotNow == pivotSaved.did) {
        return pivotSaved
    }
    if IsObject(pivotQueue[didPivotNow]) {
        return pivotQueue[didPivotNow] 
    }
    ; else
    return new pivotInfo(didPivotNow, currentTimeMS)
}

