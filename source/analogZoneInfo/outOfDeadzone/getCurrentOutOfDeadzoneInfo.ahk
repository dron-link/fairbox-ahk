#Requires AutoHotkey v1.1

getCurrentOutOfDeadzoneInfo(saved, candidate, deadzoneOutNow) {
    global currentTimeMS
    ; early Returns ahead.

    if (deadzoneOutNow == saved.out) {
        return saved
    }
    if IsObject(candidate) {
        return candidate
    } 
    ; else
    return new outOfDeadzoneInfo(deadzoneOutNow, currentTimeMS)
}