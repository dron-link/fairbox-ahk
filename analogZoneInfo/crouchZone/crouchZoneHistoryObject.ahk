#Requires AutoHotkey v1.1

class crouchZoneHistoryObject {
    unsaved := new crouchZoneHistoryEntry(false, -1000)
    queue := {}
    saved := new crouchZoneHistoryEntry(false, -1000)

    saveHistory() { ; called every time a multipress has ended
        this.saved := this.unsaved, this.queue := {}
        return
    }

    storeInfoBeforeMultipressEnds(crouchZoneOfOutput) {
        global currentTimeMS
        
        if (crouchZoneOfOutput == this.saved.zone) {
            this.unsaved := this.saved ; we haven't moved onto another zone, so the saved info still applies
        } else {
            if !IsObject(this.queue[crouchZoneOfOutput]) { ; if it's not in queue
                ; add a new entry to the queue
                this.queue[crouchZoneOfOutput] := new crouchZoneHistoryEntry(crouchZoneOfOutput, currentTimeMS)
            }
            this.unsaved := this.queue[crouchZoneOfOutput]
        }
        return
    }
}
