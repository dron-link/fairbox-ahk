#Requires AutoHotkey v1.1

class uncrouchHistoryObject {
    unsaved := new uncrouchInfo(false, -1000)
    queue := {}
    saved := new uncrouchInfo(false, -1000)
    lockout := new uncrouchInfo(false, -1000)

    saveHistory() {
        if (this.unsaved.did and this.unsaved != this.saved) {
            this.lockout := this.unsaved
        }
        this.saved := this.unsaved, this.queue := {}
        return
    }

    lockoutExpiryCheck() {
        global TIMELIMIT_DOWNUP, global currentTimeMS
        if (this.lockout.did and currentTimeMS - this.lockout.timestamp >= TIMELIMIT_DOWNUP) {
            this.lockout := new uncrouchInfo(false, currentTimeMS) ; the uncrouch nerf expired
        }
        return
    }

    storeInfoBeforeMultipressEnds(outputUncrouchDid) {
        global currentTimeMS

        if (outputUncrouchDid == this.saved.did) {
            this.unsaved := this.saved
        } else {
            if !IsObject(this.queue[outputUncrouchDid]) {
                this.queue[outputUncrouchDid] := new uncrouchInfo(outputUncrouchDid, currentTimeMS)
            }
            this.unsaved := this.queue[outputUncrouchDid]
        }

        return
    }
}