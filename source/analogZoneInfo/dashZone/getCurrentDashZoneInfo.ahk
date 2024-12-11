#Requires AutoHotkey v1

getCurrentDashZoneInfo(historyArray, candidates, currentZone) {
    global currentTimeMS

    if (currentZone == historyArray[1].zone) { ; saved.zone
        return historyArray[1] ; saved
    }
    else if IsObject(candidates[currentZone]) {
        return candidates[currentZone]
    }
    ; else
    ; we need to detect if a new pivot was inputted
    return new dashZoneHistoryEntry(currentZone, currentTimeMS
    , getPivotDid(historyArray, currentZone, currentTimeMS))
}