#Requires AutoHotkey v1

getCurrentCrouchRangeInfo(saved, candidate, isOutputInRangeNow) {
    global currentTimeMS

    if (isOutputInRangeNow == saved.in) {
        return saved
    }
    if IsObject(candidate) {
        return candidate
    }
    ; else 
    ; we need to detect if a new "uncrouch" was inputted
    return new crouchRangeHistoryEntry(isOutputInRangeNow, currentTimeMS
        , getUncrouchDid(saved.in, isOutputInRangeNow))
}