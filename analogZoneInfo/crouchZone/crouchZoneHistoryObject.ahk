#Requires AutoHotkey v1.1

class crouchZoneHistoryObject {
    unsaved := new crouchZoneHistoryEntry(false, -1000, false)
    candidates := {} ; associative array
    saved := new crouchZoneHistoryEntry(false, -1000, false)
    uncrouchLockoutEntry := new crouchZoneHistoryEntry(false, -1000, false)

    saveHistory() { ; called every time a multipress has ended
        this.saved := this.unsaved, this.candidates := {}
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
            if !IsObject(this.candidates[crouchZoneOfOutput]) { ; if it's not in candidates array
                ; add a new entry to candidates. stores whether the script outputted an "uncrouch" or not
                this.candidates[crouchZoneOfOutput] := new crouchZoneHistoryEntry(crouchZoneOfOutput
                , currentTimeMS, getUncrouchDid(this.saved.zone, crouchZoneOfOutput))
            }
            
            this.unsaved := this.candidates[crouchZoneOfOutput]
        }
        return
    }
}
