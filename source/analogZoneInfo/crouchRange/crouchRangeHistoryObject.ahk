#Requires AutoHotkey v1

class crouchRangeHistoryObject {
    unsaved := new crouchRangeHistoryEntry(false, -1000, false)
    candidate := ""
    saved := new crouchRangeHistoryEntry(false, -1000, false)
    uncrouchLockoutEntry := new crouchRangeHistoryEntry(false, -1000, false)

    saveFilteredHistory() { ; called every time a multipress has ended
        global TIMELIMIT_DOWNUP, global currentTimeMS
        if (this.saved != this.unsaved) {
            this.saved := this.unsaved
            if this.saved.uncrouch {
                this.uncrouchLockoutEntry := this.saved
            }
        }
        this.candidate := "" ; we want IsObject("") = false
        
        return
    }

    recordCrouchOutput(crouchRangeOfOutput) {
        global currentTimeMS, global TIMELIMIT_DOWNUP
        
        if (crouchRangeOfOutput == this.saved.in) {
            this.unsaved := this.saved ; we haven't moved onto another range, so the saved info still applies
        } else {
            if !IsObject(this.candidate) {
                ; store a new entry as candidate. store whether the script outputted an "uncrouch" or not
                this.candidate := new crouchRangeHistoryEntry(crouchRangeOfOutput
                , currentTimeMS, getUncrouchDid(this.saved.in, crouchRangeOfOutput))
                if this.candidate.uncrouch {
                    SetTimer, uncrouchNerfLiftTimerLabel, % - TIMELIMIT_DOWNUP
                }
            }
            
            this.unsaved := this.candidate
        }
        return
    }
}
