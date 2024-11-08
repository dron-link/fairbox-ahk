#Requires AutoHotkey v1.1

class pivotHistoryObject {
    string := "pivot"

    unsaved := new pivotInfo(false, -1000)
    queue := {}
    saved := new pivotInfo(false, -1000)
    lockout := new pivotInfo(false, -1000)

    saveHistory() {
        if (this.unsaved.did and this.unsaved.did != this.saved.did) {
            this.lockout := this.unsaved
        }
        this.saved := this.unsaved
        this.queue := {}
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

        outputDidPivot := getPivotDirection(aX, aY, dashZone)
    
        if (outputDidPivot == this.saved.did) {
            this.unsaved.did := this.saved.did
        } else {
            if !IsObject(this.queue[outputDidPivot]) {
                this.queue[outputDidPivot] := new pivotInfo(outputDidPivot, currentTimeMS)
            }
            this.unsaved := this.queue[outputDidPivot]
        }
    
        return
    }
}