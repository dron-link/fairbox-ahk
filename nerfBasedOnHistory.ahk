#Requires AutoHotkey v1.1

nerfBasedOnHistory(aX, aY, ByRef techniqueObj, zoneObj, outOfDeadzoneObj, techniqueClass) {
    global TIMELIMIT_SIMULTANEOUS
    global xComp
    global yComp
    global currentTimeMS

    techniqueObj.wasNerfed := false    

    ; we nerf if the technique was completed in the near past
    if techniqueObj.saved.did {
        techniqueObj.generateNerfedCoords(aX, aY, techniqueObj.saved, outOfDeadzoneObj)
    }
    ; we are able to overwrite aX and aY with nerfed values for the next steps
    if techniqueObj.wasNerfed {
        aX := techniqueObj.nerfedCoords[xComp], aY := techniqueObj.nerfedCoords[yComp]
    }

    if (zoneObj.zoneOf(aX, aY) != zoneObj.saved.zone) {
        ; we check if the player just completed a technique successfully
        if techniqueObj.queued.did {
            techniqueObj.unsaved := new techniqueClass(techniqueObj.detect(aX, aY, zoneObj) , techniqueObj.queued.timestamp)
        } else {
            ; a brand new technique completion was detected
            techniqueObj.unsaved := new techniqueClass(techniqueObj.detect(aX, aY, zoneObj), currentTimeMS)
        }      
    }

    ; take care to not nerf the same coordinates twice
    if (techniqueObj.unsaved.did and !techniqueObj.wasNerfed) {
        techniqueObj.generateNerfedCoords(aX, aY, techniqueObj.unsaved, outOfDeadzoneObj)
    }  
    return
}
