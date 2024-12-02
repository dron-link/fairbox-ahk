#Requires AutoHotkey v1.1

getCurrentOutOfDeadzoneInfo(saved, candidates, deadzoneOutNow) {
    global currentTimeMS
    ; early Returns ahead.

    if (deadzoneOutNow == saved.out) {
        return saved
    }
    if IsObject(candidates[deadzoneOutNow]) {
        return candidates[deadzoneOutNow]
    } 
    ; else
    return new outOfDeadzoneInfo(deadzoneOutNow, currentTimeMS)
}