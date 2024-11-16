#Requires AutoHotkey v1.1

class pivotHistoryObject {
    unsaved := new pivotInfo(false, -1000)
    queue := {}
    saved := new pivotInfo(false, -1000)
    lockout := new pivotInfo(false, -1000)

    saveHistory() {
        /*  if the player just performed a pivot
            and it's a distinct instance from the previous pivot
        */
        if (this.unsaved.did and this.unsaved != this.saved) {
            this.lockout := this.unsaved
        }
        this.saved := this.unsaved, this.queue := {}
    }

    lockoutExpiryCheck() {
        global TIMELIMIT_PIVOTTILT, global currentTimeMS
        if (this.lockout.did and currentTimeMS - this.lockout.timestamp >= TIMELIMIT_PIVOTTILT) {
            this.lockout := new pivotInfo(false, currentTimeMS)
        }
        return
    }

    storeInfoBeforeMultipressEnds(aX, aY, dashZone) {
        global currentTimeMS

        outputDidPivot := getDidPivot(aX, aY, dashZone)
    
        if (outputDidPivot == this.saved.did) {
            this.unsaved := this.saved
        } else {
            if !IsObject(this.queue[outputDidPivot]) {
                this.queue[outputDidPivot] := new pivotInfo(outputDidPivot, currentTimeMS)
            }
            this.unsaved := this.queue[outputDidPivot]
        }
    
        return
    }
}