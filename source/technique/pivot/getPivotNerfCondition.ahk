#Requires AutoHotkey v1

getPivotNerfCondition(aX, aY, outOfDeadzone, relevantDashZoneInfo) {
    global TIMELIMIT_TAPSHUTOFF, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_PIVOTTILT_YDASH
    global P_RIGHTLEFT, global P_LEFTRIGHT
    global PNERF_EXTEND, global PNERF_UP_45DEG
    global PNERF_YDASH_RIGHTLEFT, global PNERF_YDASH_LEFTRIGHT
    global currentTimeMS

    ; guard clause
    if (!relevantDashZoneInfo.pivot
        or currentTimeMS - relevantDashZoneInfo.timestamp >= TIMELIMIT_PIVOTTILT) {
        return false ; No pivot or all pivot nerfs expired.
    }
    
    ; else, if we are within the nerf time window:

    condition := false ; we assume no nerfs by default

    if getIsOutOfDeadzoneDown(aY) {
        downYTimestamp := getCurrentOutOfDeadzoneTimestamp(outOfDeadzone.down.saved
        , outOfDeadzone.down.candidate, TRUE)
        ; if the player hasn't shut off tap downsmash
        if (currentTimeMS - downYTimestamp < TIMELIMIT_TAPSHUTOFF) {
            condition := PNERF_EXTEND
        }

        ; if the player shut off tap downsmash, by pivoting with downY dashes
        else if (downYTimestamp < relevantDashZoneInfo.timestamp
            and currentTimeMS - relevantDashZoneInfo.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
            condition := (relevantDashZoneInfo.pivot == P_RIGHTLEFT
            ? PNERF_YDASH_RIGHTLEFT : PNERF_YDASH_LEFTRIGHT)
        }

        ; if the player shut off tap downsmash without pivoting with downY dashes we refrain from nerfing.
    }

    else if getIsOutOfDeadzoneUp(aY) {
        upYTimestamp := getCurrentOutOfDeadzoneTimestamp(outOfDeadzone.up.saved
        , outOfDeadzone.up.candidate, TRUE)
        /*  if we are in the up region
            and the player has not shut off tap jump
            or the player has shut off tap jump but not with actions done before
            completing the pivot (upY dashes)
        */
        if (currentTimeMS - upYTimestamp < TIMELIMIT_TAPSHUTOFF
            or upYTimestamp >= relevantDashZoneInfo.timestamp) {
            condition := (Abs(aX) > aY) ? PNERF_UP_45DEG : PNERF_EXTEND
        }
        /*  if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes.
            nerf only active for TIMELIMIT_PIVOTTILT_YDASH ms after pivot (5 frames total
            as of writing this)
        */
        else if (currentTimeMS - relevantDashZoneInfo.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
            condition := (relevantDashZoneInfo.pivot == P_RIGHTLEFT
            ? PNERF_YDASH_RIGHTLEFT : PNERF_YDASH_LEFTRIGHT)
        }
    }

    return condition
}