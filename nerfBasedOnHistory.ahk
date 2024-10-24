#Requires AutoHotkey v1.1

nerfBasedOnHistory(aX, aY, ByRef techniqueObj, zoneObj, techniqueInfo) {
    global TIMELIMIT_SIMULTANEOUS, global xComp, global yComp, global currentTimeMS

    techniqueObj.wasNerfed := false    

    ; we nerf if the technique was completed in the near past
    if techniqueObj.lockout.did {
        techniqueObj.generateNerfedCoords(aX, aY, techniqueObj.lockout)
    }
    ; we are able to overwrite aX and aY with nerfed values for the next steps
    if techniqueObj.wasNerfed {
        aX := techniqueObj.nerfedCoords[xComp], aY := techniqueObj.nerfedCoords[yComp]
    }

    techniqueInputInfo := techniqueObj.getCurrentInfo(aX, aY, zoneObj)
    ; take care to not nerf the same coordinates twice
    if (techniqueInputInfo.did and !techniqueObj.wasNerfed) {
        techniqueObj.generateNerfedCoords(aX, aY, techniqueInputInfo)
    }  
    return
}
