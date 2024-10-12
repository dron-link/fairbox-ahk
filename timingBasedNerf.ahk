#Requires AutoHotkey v1.1

timingBasedNerf(aX, aY, ByRef techniqueObj, zoneObj, timelimitActionBan, tInfoBase) {
    global currentTimeMS
    global TIMELIMIT_SIMULTANEOUS
    
    techniqueObj.wasLookedFor := false
    techniqueObj.nerfWasCalc := false
    
    /*
        Techniques, such as burst SDI, empty pivots and uncrouch uptilt are performed by changing analog
        zones following a pattern. The technique is considered complete when the last input
        of that sequence is read by this function.
        ----
        If the zone of the player input changes, we need to see if it marks a successful input of a technique:
    */
    if(zoneObj.zoneOf(aX, aY) != zoneObj.lastDelivered.zone) {
        ; techniqueObj.detect() looks through saved zone entries
        techniqueObj.fromDetector := new tInfoBase(techniqueObj.detect(aX, aY, zoneObj), currentTimeMS)
        techniqueObj.wasLookedFor := true
        if techniqueObj.fromDetector.did {
            techniqueObj.jump2F.force := false
            techniqueObj.nerfedCoords := techniqueObj.nerf(aX, aY, "fromDetector")
        } else if techniqueObj.queued.did {
            ; player spoiled the queued technique
            techniqueObj.jump2F.force := false
        }
    }

    /*
        if the detector didn't alert of a newfound technique and nerfed it,
        we check to see if we need to nerf based on previous technique executions
    */
    if !techniqueObj.nerfWasCalc {
        ; this will run if we detected that current input is not successful at executing a technique
        if (!techniqueObj.wasLookedFor and techniqueObj.queued.did) { ; info: queued.did is false after saving
            techniqueObj.nerfedCoords := techniqueObj.nerf(aX, aY, "queued")
        }
        ; nerfing the output is considered until timelimitActionBan milliseconds pass
        else if (currentTimeMS - techniqueObj.saved.timestamp < timelimitActionBan) {
            techniqueObj.nerfedCoords := techniqueObj.nerf(aX, aY, "saved")
            
        } else { ; no reason found for nerfing
            techniqueObj.jump2F.force := false
        }
    }
    return
}

; OutputDebug, % techniqueObj.string " "      "`n"
