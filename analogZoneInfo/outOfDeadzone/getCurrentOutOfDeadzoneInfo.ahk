#Requires AutoHotkey v1.1

getCurrentOutOfDeadzoneInfo(saved, queueArray, deadzoneOutNow) {
    global currentTimeMS
    ; early Returns ahead.

    if (deadzoneOutNow == saved.out) {
        return saved
    }
    if IsObject(queueArray[deadzoneOutNow]) {
        return queueArray[deadzoneOutNow]
    } 
    ; else
    return new outOfDeadzoneInfo(deadzoneOutNow, currentTimeMS)
}