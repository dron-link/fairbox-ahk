#Requires AutoHotkey v1.1

ANALOG_HISTORY_LENGTH := 5 ; MINIMUM 1
SDI_HISTORY_LENGTH := 5 ; MINIMUM 5
DASH_HISTORY_LENGTH := 3 ; MINIMUM 3

; named values------------------------------------------------------------------------------

DIDNT_SCAN := -1
P_NONE := 0, P_RIGHTLEFT := 1, P_LEFTRIGHT := 2 ; id: no pivot, right to left pivot, or left to right pivot 
U_NO := 0 , U_YES := 1 ; id: no uncrouch or did uncrouch. (uncrouch detector function return)
NOT_DASH := 0 ; id: when the x coordinate is in neither of the zones that trigger dash
ZONE_CENTER := 0 ; id: when the x and y coordinate is in no zone that can trigger SDI
; for bitwise calculations:
ZONE_DIR := ((1<<4) - 1)  ; 0b0000'1111
ZONE_U := 1               ; 0b0000'0001
ZONE_D := 1<<1            ; 0b0000'0010
ZONE_L := 1<<2
ZONE_R := 1<<3
BITS_SDI := ((1<<4) - 1) << 4 ; 0b1111'0000
BITS_SDI_QUARTERC := 1<<4     ; 0b0001'0000
BITS_SDI_TAP_CARD := 1<<5     ; 0b0010'0000
BITS_SDI_TAP_DIAG := 1<<6
BITS_SDI_TAP_CRDG := 1<<7
; direction types per sdi popcount
POP_CENTER := 0, POP_CARD := 1, POP_DIAG := 2
; analog history simultaneousFinish bits
FINAL_DASHZONE := 1, FINAL_SDIZONE := 1<<1, FINAL_CROUCHRANGE := 1<<2

; coordinate components simple array keys
xComp := 1, yComp := 2


; to store input info ----------------------------------------------------------------------
currentTimeMS := 0
nerfLiftFire := false ; if a nerf lift timer fires this will be set true
upY := false ; if current Y is above deadzone 
upYTimestamp := -1000
downY := false
downYTimestamp := -1000
pivotForce2FJumpTimestamp := -1000   ; CarVac HayBox timed nerf. Inactive by default.
pivotForced2FJump := false                ; <--- Search references for this
uncrouchForced2FJump := false               ; <-- and this if you want to activate it
uncrouchForce2FJumpTimestamp := -1000

finalCoords := [0, 0] ; left stick coordinates that are intended to be sent to vjoy



; analog history
class analogHistoryEntry {
  x := 0, y := 0, timestamp := -1000, simultaneousFinish := 0
}
analogHistory := []
Loop, % ANALOG_HISTORY_LENGTH {
  analogHistory.Push(new analogHistoryEntry)
}
currentIndexA := 1 ; the index for accessing analog history


; // for sdi nerfs, we want to record only movement between sdi zones, ignoring movement within zones
class sdiZoneHistoryEntry {
  timestamp := -1000, stale := true, zone := ZONE_CENTER, popcount := 0
}
sdiZoneHist := []
Loop, % SDI_HISTORY_LENGTH {
  sdiZoneHist.Push(new sdiZoneHistoryEntry)
}
sdiSimultZone := ZONE_CENTER
sdiSimultTimestamp := -1000

; // for pivot nerfs, we want to record only movement between dash zones, ignoring movement within zones
class dashZoneHistoryEntry {
  timestamp := -1000, stale := true, zone := NOT_DASH
}
dashZoneHist := []
Loop, % DASH_HISTORY_LENGTH {
  dashZoneHist.Push(new dashZoneHistoryEntry)
}

dashZone := {unsaved : NOT_DASH}
dashZoneTimestamp := {unsaved : -1000, simultaneous : -1000}
pivotDirection := {fromDetector : P_NONE, unsaved : P_NONE, saved : P_NONE} ; pivot values : P_NONE , P_RIGHTLEFT , P_LEFTRIGHT
pivotTimestamp := {fromDetector : -1000, unsaved : -1000, saved : -1000}
pivotWasNerfed := false

crouchRange := {unsaved : false, saved : false}
crouchRangeTimestamp := {simultaneous : -1000}
uncrouchTimestamp := {fromDetector : -1000, unsaved : -1000, saved : -1000}
uncrouched := {fromDetector : false, unsaved : false, saved : false}
uncrouchWasNerfed := false
