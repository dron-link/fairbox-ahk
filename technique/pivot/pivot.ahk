#Requires AutoHotkey v1.1

getCurrentPivotInfo(aX, aY, didPivotNow, pivot) {
    global currentTimeMS

    if (didPivotNow == pivot.saved.did) {
        return pivot.saved
    } else if IsObject(pivot.queue[didPivotNow]) {
        return pivot.queue[didPivotNow] 
    } else {
        return new pivotInfo(didPivotNow, currentTimeMS)
    }

}

storePivotsBeforeMultipressEnds(aX, aY, outputDidPivot, ByRef pivot) {
    global currentTimeMS

    if (outputDidPivot == pivot.saved.did) {
        pivot.unsaved.did := pivot.saved.did
    } else {
        if !IsObject(pivot.queue[outputDidPivot]) {
            pivot.queue[outputDidPivot] := new pivotInfo(outputDidPivot, currentTimeMS)
        }
        pivot.unsaved := pivot.queue[outputDidPivot]
    }

    return
}
