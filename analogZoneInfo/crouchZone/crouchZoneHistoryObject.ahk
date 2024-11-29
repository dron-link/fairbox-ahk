#Requires AutoHotkey v1.1

class crouchZoneHistoryObject {
    unsaved := new crouchZoneHistoryEntry(false, -1000, false)
    queue := {} ; associative array
    saved := new crouchZoneHistoryEntry(false, -1000, false)
    uncrouchLockoutEntry := new crouchZoneHistoryEntry(false, -1000, false)

    saveHistory() { ; called every time a multipress has ended
        this.saved := this.unsaved, this.queue := {}
        if this.saved.uncrouch {
            this.uncrouchLockoutEntry := this.saved
        }
        return
    }

    storeInfoBeforeMultipressEnds(crouchZoneOfOutput) {
        global currentTimeMS
        
        if (crouchZoneOfOutput == this.saved.zone) {
            this.unsaved := this.saved ; we haven't moved onto another zone, so the saved info still applies
        } else {
            if !IsObject(this.queue[crouchZoneOfOutput]) { ; if it's not in queue
                ; add a new entry to the queue. stores whether the script outputted an "uncrouch" or not
                this.queue[crouchZoneOfOutput] := new crouchZoneHistoryEntry(crouchZoneOfOutput
                    , currentTimeMS, getUncrouchDid(this.saved.zone, crouchZoneOfOutput))
            }
            
            this.unsaved := this.queue[crouchZoneOfOutput]
        }
        return
    }
}
