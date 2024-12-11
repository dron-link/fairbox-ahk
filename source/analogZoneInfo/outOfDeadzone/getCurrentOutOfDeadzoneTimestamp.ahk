#Requires AutoHotkey v1.1

getCurrentOutOfDeadzoneTimestamp(saved, candidate, deadzoneOutNow) {
    global currentTimeMS
    ; early Returns ahead.

    if (deadzoneOutNow == saved.out) {
        return saved.timestamp
    }
    if IsObject(candidate) {
        return candidate.timestamp
    } 
    ; else
    return currentTimeMS
}