#Requires AutoHotkey v1.1

class techniqueClassThatHasTimingLockouts {
    __New(did, timestamp) {
        this.did := did
        this.timestamp := timestamp
    }
}

SDI_HISTORY_LENGTH := 6 ; MINIMUM 5

; named values------------------------------------------------------------------------------

/*
    P_X, U_X and BITS_SDI_X technique values are affirmations and must be different to 0,
    as 0 (false) will serve as the negation of technique
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
