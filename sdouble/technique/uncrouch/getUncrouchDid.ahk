#Requires AutoHotkey v1

getUncrouchDid(savedInCrouchRange, nowInCrouchRange) {
    global returnGetUncrouchDid, global returnError
    global expectGetUncrouchDid_sav, global expectGetUncrouchDid_now

    if (savedInCrouchRange == expectGetUncrouchDid_sav and nowInCrouchRange == expectGetUncrouchDid_now) {
        return returnGetUncrouchDid
    }
    ;else
    return returnError
}