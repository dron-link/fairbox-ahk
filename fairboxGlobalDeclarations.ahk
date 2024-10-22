#Requires AutoHotkey v1.1

; can i migrate everything that is in here?

SDI_HISTORY_LENGTH := 6 ; MINIMUM 5

; named values------------------------------------------------------------------------------

/*
    P_X, U_X and BITS_SDI_X values are affirmations and must be different to 0,
    as false will serve to indicate the negation of technique
*/

P_RIGHTLEFT := 1 ; id: right to left empty pivot
P_LEFTRIGHT := 2 ; id: left to right pivot
U_YES := 1 ; id: uncrouch
ZONE_CENTER := 0 ; id: in the zone of analog stick neutral
ZONE_U := 1 ; 0b0000'0001
ZONE_D := 1<<1 ; 0b0000'0010
ZONE_L := 1<<2
ZONE_R := 1<<3
; for bitwise calculations:
ZONE_DIR := ((1<<4) - 1) ; 0b0000'1111
BITS_SDI := ((1<<4) - 1) << 4 ; 0b1111'0000
BITS_SDI_QUARTERC := 1<<4 ; 0b0001'0000
BITS_SDI_TAP_CARD := 1<<5 ; 0b0010'0000
BITS_SDI_TAP_DIAG := 1<<6
BITS_SDI_TAP_CRDG := 1<<7
; direction types per sdi popcount
POP_CENTER := 0, POP_CARD := 1, POP_DIAG := 2
; analog history simultaneousFinish bits
FINAL_DASHZONE := 1, FINAL_SDIZONE := 1<<1, FINAL_CROUCHRANGE := 1<<2

; coordinate components simple array keys
xComp := 1, yComp := 2

; to store input info ----------------------------------------------------------------------
limitOutputsInitialized := false

currentTimeMS := 0
nerfLiftFire := false ; if a nerf lift timer fires this will be set true

finalCoords := [0, 0] ; left stick coordinates that are intended to be sent to vjoy

; analog history
class outputHistoryEntry {
    __New(x, y, timestamp, multipressBegan, multipressEnded, cx, cy, a, b) {
        ;         1            2                    3
        this.x := x, this.y := y, this.timestamp := timestamp
        ;                           4                        5
        this.multipress := {began : multipressBegan, ended : multipressEnded}
        ;          6              7             8            9
        this.cx := cx, this.cy := cy, this.a := a, this.b := b
    }
}

class outputBase {

    static historyLength := 15
    limited := ""
    latestMultipressBeginningTimestamp := -1000

    __New() {
        this.hist := []
        Loop, % this.historyLength {
            this.hist.Push(new outputHistoryEntry(0, 0, -1000
            , false, true, 0, 0, false, false))
        }
    }
}

class deadzoneExitInfo {
    __New(did, timestamp) {
        this.did := did
        this.timestamp := timestamp
    }
}
class analogDeadzoneExitBase {

    class up {
        unsaved := new deadzoneExitInfo(false, -1000)
        queued := new deadzoneExitInfo(false, -1000)
        saved := new deadzoneExitInfo(false, -1000)
        is(aY) {
            global ANALOG_DEAD_MAX
            return (aY > ANALOG_DEAD_MAX)
        }
    }
    
    class down {
        unsaved := new deadzoneExitInfo(false, -1000)
        queued := new deadzoneExitInfo(false, -1000)
        saved := new deadzoneExitInfo(false, -1000)
        is(aY) {
            global ANALOG_DEAD_MIN
            return (aY < ANALOG_DEAD_MIN)
        }
    }    
}
