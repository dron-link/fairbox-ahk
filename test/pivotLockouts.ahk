#Requires AutoHotkey v1

#Include %A_WorkingDir%\source\analogZoneInfo\analogZoneInfo.ahk
#Include %A_WorkingDir%\source\coordinates\bringToCircleBorder.ahk
#Include %A_WorkingDir%\source\coordinates\trimToCircle.ahk
#Include %A_WorkingDir%\source\limitOutputs\limitOutputs.ahk
#Include %A_WorkingDir%\source\system\fairboxConstants.ahk
#Include %A_WorkingDir%\source\system\gameEngineConstants.ahk
#Include %A_WorkingDir%\source\system\hotkeys.ahk
#Include %A_WorkingDir%\source\technique\technique.ahk

#Include %A_WorkingDir%\logAppend.ahk

logAppend("pivotLockouts")
logAppend(A_LineFile "`n")

TIMELIMIT_SIMULTANEOUS := 4 ; smallest quantity after the millisecond...
                            ; we should be sure at all times of its value

addTimeFPFix(time) {
    global currentTimeMS
    currentTimeMS += time + 0.000001
    ; return
}

logExpect(out, expected, title) {
    global xComp, global yComp
    if (out.x != expected[xComp] or out.y != expected[yComp]) {
        logAppend(title ": unexpected output. " 
        . "[" expected[xComp] ", " expected[yComp] "] => out.x " out.x " out.y " out.y)
    }
}

currentTimeMS := 0
getOutputLimited(0, 0)

currentTimeMS += 1000 ; clear actions recency

; pivot ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

; test FORCE_FTILT... both dashup and dashdown, p_rightleft and p_leftright, what nerfs appear in the y directions?

; if the player hasn't shut off tap downsmash
PNERF_EXTEND

; if the player shut off tap downsmash, by pivoting with downY dashes
PNERF_YDASH

; if the player shut off tap downsmash without pivoting with downY dashes we refrain from nerfing.


; if we are in the up region
; and the player has not shut off tap jump
; or the player has shut off tap jump but not with actions done before
; completing the pivot (upY dashes)
(Abs(aX) > aY) ? PNERF_UP_45DEG : PNERF_EXTEND

; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes.
; nerf only active for TIMELIMIT_PIVOTTILT_YDASH ms after pivot (5 frames total
; as of writing this)
PNERF_YDASH

*/

; pivot setup
getOutputLimited(-80, 0) ; left
currentTimeMS += TIMELIMIT_SIMULTANEOUS
getOutputLimited(80, 0) ; right
currentTimeMS += TIMELIMIT_FRAME ; wait around 1 frame before dash stop

; no-wait nerf
; uptilt (locked out)
logExpect(getOutputLimited(0, 25), bringToCircleBorder([0, 25])
, "pivot (L --> R). uptilt lockout")

; downtilt (locked out)
logExpect(getOutputLimited(0, -25), bringToCircleBorder([0, -25])
, "pivot. dtilt lockout")

; turn right uptilt (locked out)
logExpect(getOutputLimited(25, 35), bringToCircleBorder([25, 35])
, "pivot. turn right uptilt lockout")

; ftilt up left (locked out, redirected to 45 degrees)
logExpect(getOutputLimited(-40, 25), bringToCircleBorder([-55, 55])
, "pivot. ftilt up left lockout")

; ftilt down left (locked out)
logExpect(getOutputLimited(-40, -25), bringToCircleBorder([-40, -25])
, "pivot. ftilt down left lockout")

; insta spoil by target
logExpect(getOutputLimited(ANALOG_DASH_LEFT-2, 25), [ANALOG_DASH_LEFT-2, 25]
, "pivot. insta spoil by dash up+left")
logExpect(getOutputLimited(ANALOG_DASH_RIGHT+2, -25), [ANALOG_DASH_RIGHT+2, -25]
, "pivot. insta spoil by dash down+right")

; finish performing pivot, then save it. nerfs will apply for the duration of TIMELIMIT_PIVOTTILT
getOutputLimited(0, 0)
currentTimeMS += TIMELIMIT_SIMULTANEOUS

; saved pivots cant be spoiled
logExpect(getOutputLimited(40, 25), bringToCircleBorder([55, 55])
, "pivot. ftilt up+right timing lockout nerf")
getOutputLimited(80, 0) ; dash right to pretend to be able to spoil the previous pivot
currentTimeMS += TIMELIMIT_SIMULTANEOUS ; not the proper timing for a new pivot
logExpect(getOutputLimited(40, 25), bringToCircleBorder([55, 55])
, "pivot. ftilt up+right timing lockout nerf")

; expire lockout
currentTimeMS += 1000 
logExpect(getOutputLimited(40, 25), [40, 25], "pivot. lockout expiration (slow version)")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; pivot setup
getOutputLimited(80, 0) ; right
currentTimeMS += TIMELIMIT_SIMULTANEOUS
getOutputLimited(-80, 0) ; left
currentTimeMS += TIMELIMIT_FRAME ; wait around 1 frame before dash stop

; spoil by nerf
logExpect(getOutputLimited(ANALOG_DASH_LEFT+2, -25), bringToCircleBorder([ANALOG_DASH_LEFT+2, -25])
, "pivot (R --> L). insta nerf, extend past dash stop")
currentTimeMS += TIMELIMIT_FRAME ; normal nerf takes about 8 frames. advancing 1 frame only lifts nerfs that come
                                 ; from spoiled pivots. +1 frame was chosen in order to total 2 frames
                                 ; of leftwards dash action
logExpect(getOutputLimited(25, 25), [25, 25], "pivot. spoil via insta nerf")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; up dash pivot setup
getOutputLimited(ANALOG_DASH_RIGHT+2, 25)
currentTimeMS += TIMELIMIT_TAPSHUTOFF - TIMELIMIT_FRAME
getOutputLimited(ANALOG_DASH_LEFT-2, 25)
currentTimeMS += TIMELIMIT_FRAME ; time since upY: TIMELIMIT_TAPSHUTOFF

logExpect(getOutputLimited(0, 10), [0, 10], "up dash pivot. not forcing upwards ftilt")

; downtilt (normal locked out)
logExpect(getOutputLimited(0, -25), bringToCircleBorder([0, -25]), "up dash pivot (R --> L). insta dtilt lockout")

; ftilt down left (normal locked out)
logExpect(getOutputLimited(-40, -25), bringToCircleBorder([-40, -25])
, "up dash pivot. insta ftilt down left lockout")

; force ftilt up+left
logExpect(getOutputLimited(0, 25), [-FORCE_FTILT, FORCE_FTILT]
, "up dash pivot. insta uptilt --> force ftilt up+left")
logExpect(getOutputLimited(0, 80), [-FORCE_FTILT, FORCE_FTILT]
, "up dash pivot. insta tapjump --> force ftilt up+left")
logExpect(getOutputLimited(55, 55), [-FORCE_FTILT, FORCE_FTILT]
, "up dash pivot. insta ftilt up+right --> force ftilt up+left")
logExpect(getOutputLimited(-55, 55), [-FORCE_FTILT, FORCE_FTILT]
, "up dash pivot. insta ftilt up+left --> force ftilt up+left")

; insta spoil by target
logExpect(getOutputLimited(ANALOG_DASH_RIGHT+2, 25), [ANALOG_DASH_RIGHT+2, 25]
, "up dash pivot. insta spoil by target dash right")
logExpect(getOutputLimited(ANALOG_DASH_LEFT-2, 25), [ANALOG_DASH_LEFT-2, 25]
, "up dash pivot. insta spoil by target dash left")

; perform pivot and save, indirectly filter all previous
; y movement except not exiting the upY zone
getOutputLimited(0, 25) 
currentTimeMS += TIMELIMIT_SIMULTANEOUS
; time passed since upY: TIMELIMIT_TAPSHUTOFF + TIMELIMIT_SIMULTANEOUS
; since pivot: TIMELIMIT_SIMULTANEOUS

; pivot can't be spoiled with dashes now that it's saved. we demonstrate it by upY dashing
logExpect(getOutputLimited(ANALOG_DASH_RIGHT+2, 25), [-FORCE_FTILT, FORCE_FTILT]
, "up dash pivot (saved). dash right+up --> force ftilt up+left")
logExpect(getOutputLimited(ANALOG_DASH_LEFT-2, 25), [-FORCE_FTILT, FORCE_FTILT]
, "up dash pivot (saved). dash left+up --> force ftilt up+left")

; downtilt (normal locked out)
logExpect(getOutputLimited(0, -25), bringToCircleBorder([0, -25]), "up dash pivot. saved pivot dtilt lockout")

; ftilt down right (normal locked out)
logExpect(getOutputLimited(40, -25), bringToCircleBorder([40, -25])
, "up dash pivot. saved pivot ftilt down+right lockout")

; deactivate force ftilt up-left by exiting upY and saving
getOutputLimited(0, 0)
currentTimeMS += TIMELIMIT_SIMULTANEOUS
; time passed since pivot: 2 * TIMELIMIT_SIMULTANEOUS

; uptilt (normal locked out due to force ftilt deactivation)
logExpect(getOutputLimited(0, 25), bringToCircleBorder([0, 25])
, "up dash pivot. uptilt lockout, after force ftilt deactivation")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; up dash pivot facing to the right
getOutputLimited(ANALOG_DASH_LEFT-2, 25)
currentTimeMS += TIMELIMIT_TAPSHUTOFF - TIMELIMIT_FRAME
getOutputLimited(ANALOG_DASH_RIGHT+2, 25)
currentTimeMS += TIMELIMIT_FRAME ; time since upY: TIMELIMIT_TAPSHUTOFF

; save up y pivot
getOutputLimited(0, 25)
currentTimeMS += TIMELIMIT_SIMULTANEOUS

logExpect(getOutputLimited(0, 25), [FORCE_FTILT, FORCE_FTILT]
, "up dash pivot. insta uptilt --> force ftilt up+right")

getOutputLimited(0, 25) ; preserve upY
currentTimeMS += TIMELIMIT_SIMULTANEOUS ; save pivot

; pivot can't be spoiled with dashes now that it's saved. we demonstrate it by upY dashing
logExpect(getOutputLimited(ANALOG_DASH_RIGHT+2, 25), [FORCE_FTILT, FORCE_FTILT]
, "up dash pivot (saved). dash right+up --> force ftilt up+right")
logExpect(getOutputLimited(ANALOG_DASH_LEFT-2, 25), [FORCE_FTILT, FORCE_FTILT]
, "up dash pivot (saved). dash left+up --> force ftilt up+right")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; down dash pivot facing to the left
getOutputLimited(ANALOG_DASH_RIGHT+2, -25)
currentTimeMS += TIMELIMIT_TAPSHUTOFF - TIMELIMIT_SIMULTANEOUS - TIMELIMIT_FRAME
getOutputLimited(0, -25)
currentTimeMS += TIMELIMIT_SIMULTANEOUS
getOutputLimited(ANALOG_DASH_LEFT-2, -25)
currentTimeMS += TIMELIMIT_FRAME

; save down y pivot
getOutputLimited(0, -25)
currentTimeMS += TIMELIMIT_SIMULTANEOUS

logExpect(getOutputLimited(0, -10), [0, -10]
, "down dash pivot. not forcing downwards ftilt")

; uptilt (normal lockout)
logExpect(getOutputLimited(0, 25), bringToCircleBorder([0, 25])
, "down dash pivot (R --> center --> L). uptilt normal lockout")
; ftilt up right (normal lockout)
logExpect(getOutputLimited(40, 25), bringToCircleBorder([55, 55])
, "down dash pivot (R --> center --> L). ftilt up+right normal lockout")

; if the player doesn't target dash, nerf should always be forcing ftilt
logExpect(getOutputLimited(0, -25), [-FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. dtilt --> force ftilt left+down")
logExpect(getOutputLimited(0, -80), [-FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. dsmash --> force ftilt left+down")
logExpect(getOutputLimited(-40, -25), [-FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. ftilt left+down --> force ftilt left+down")
logExpect(getOutputLimited(40, -25), [-FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. ftilt right+down --> force ftilt left+down")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; down dash pivot facing to the right
getOutputLimited(ANALOG_DASH_LEFT-2, -25)
currentTimeMS += TIMELIMIT_TAPSHUTOFF - TIMELIMIT_FRAME
getOutputLimited(ANALOG_DASH_RIGHT+2, -25)
currentTimeMS += TIMELIMIT_FRAME

; save down y pivot
getOutputLimited(0, -25)
currentTimeMS += TIMELIMIT_SIMULTANEOUS

; if the player doesn't target dash, nerf should always be forcing ftilt
logExpect(getOutputLimited(0, -25), [FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. dtilt --> force ftilt right+down")
logExpect(getOutputLimited(0, -80), [FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. dsmash --> force ftilt right+down")
logExpect(getOutputLimited(-40, -25), [FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. ftilt left+down --> force right left+down")
logExpect(getOutputLimited(40, -25), [FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot. ftilt right+down --> force right left+down")


/*

timing mix



*/

getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; pivot setup
getOutputLimited(-80, 0) ; left
currentTimeMS += TIMELIMIT_SIMULTANEOUS
getOutputLimited(0, 0) ; dash stop
currentTimeMS += TIMELIMIT_SIMULTANEOUS
getOutputLimited(80, 0) ; right
currentTimeMS += TIMELIMIT_FRAME ; wait around 1 frame before dash stop

; edge cases of upwards nerf lockout expiration
logExpect(getOutputLimited(40, 25), bringToCircleBorder([55, 55])
, "pivot (L --> stop --> R). ftilt up+right insta lockout nerf")
currentTimeMS += TIMELIMIT_PIVOTTILT - 1
logExpect(getOutputLimited(40, 25), bringToCircleBorder([55, 55])
, "pivot. ftilt up+right timing lockout nerf edge case")

; demonstrate that if the player doesn't hold the analog stick down, nerfs will
; await when trying to tilt downwards
logExpect(getOutputLimited(-40, -25), bringToCircleBorder([-40, -25])
, "pivot. ftilt down+left timing lockout nerf edge case")

; this is the very millisecond the nerfs end, plus floating point imprecision tolerance
currentTimeMS += 1 + 0.000001 
logExpect(getOutputLimited(40, 25), [40, 25], "pivot. lockout expiration edge case")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; pivot setup
getOutputLimited(-80, 0) ; left
currentTimeMS += TIMELIMIT_SIMULTANEOUS
getOutputLimited(0, 0) ; center
currentTimeMS += TIMELIMIT_SIMULTANEOUS
getOutputLimited(80, 0) ; right
currentTimeMS += TIMELIMIT_FRAME ; wait around 1 frame before dash stop

; downY nerf lockout expiry by holding downY for the duration of the tap interval
logExpect(getOutputLimited(0, -25), bringToCircleBorder([0, -25])
, "pivot (L --> stop --> R). insta d-tilt nerf")
currentTimeMS += TIMELIMIT_TAPSHUTOFF - 1 ; held for the duration of the tap interval minus 1ms
logExpect(getOutputLimited(0, -25), bringToCircleBorder([0, -25])
, "pivot. d-tilt nerf hold down lockout timing edge case")
currentTimeMS += 1 + 0.000001
logExpect(getOutputLimited(0, -25), [0, -25]
, "pivot. downY lockout expiry due to holding stick down")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; up dash pivot facing to the right
getOutputLimited(ANALOG_DASH_LEFT-2, 25)
currentTimeMS += TIMELIMIT_TAPSHUTOFF - TIMELIMIT_FRAME
getOutputLimited(ANALOG_DASH_RIGHT+2, 25)
currentTimeMS += TIMELIMIT_FRAME + 0.000001 ; time since upY: TIMELIMIT_TAPSHUTOFF

; demonstrate nerf
logExpect(getOutputLimited(0, 25), [FORCE_FTILT, FORCE_FTILT]
, "up dash pivot facing right. insta uptilt --> force ftilt up+right")
; edge cases for ydash nerf
currentTimeMS += TIMELIMIT_PIVOTTILT_YDASH - 1
logExpect(getOutputLimited(0, 25), [FORCE_FTILT, FORCE_FTILT]
, "up dash pivot. force ftilt timing edge case")
currentTimeMS += 1 + 0.000001
logExpect(getOutputLimited(0, 25), [0, 25]
, "up dash pivot. force ftilt timelimit expiration")
; other nerfs remain
currentTimeMS += TIMELIMIT_PIVOTTILT - TIMELIMIT_PIVOTTILT_YDASH - 1 ; about 3 frames
logExpect(getOutputLimited(0, -25), bringToCircleBorder([0, -25])
, "up dash pivot. downY extend-nerf timing edge case")
currentTimeMS += 1 + 0.000001
logExpect(getOutputLimited(0, -25), [0, -25]
, "up dash pivot. downY extend-nerf timelimit expiration")



getOutputLimited(0, 0)
currentTimeMS += 1000 ; clear actions recency

; down dash pivot facing to the left
getOutputLimited(ANALOG_DASH_RIGHT+2, -25)
currentTimeMS += TIMELIMIT_TAPSHUTOFF - TIMELIMIT_FRAME
getOutputLimited(ANALOG_DASH_LEFT-2, -25)
currentTimeMS += TIMELIMIT_FRAME + 0.000001

; demonstrate nerf
logExpect(getOutputLimited(0, -25), [-FORCE_FTILT, -FORCE_FTILT]
, "down dash pivot facing left. insta downtilt --> force ftilt down+left")
; edge cases for ydash nerf
currentTimeMS += TIMELIMIT_PIVOTTILT_YDASH - 1
logExpect(getOutputLimited(0, -25), [-FORCE_FTILT, -FORCE_FTILT]
, "downup dash pivot. force ftilt timing edge case")
currentTimeMS += 1 + 0.000001
logExpect(getOutputLimited(0, -25), [0, -25]
, "down dash pivot. force ftilt timelimit expiration")
; other nerfs remain
currentTimeMS += TIMELIMIT_PIVOTTILT - TIMELIMIT_PIVOTTILT_YDASH - 1 ; about 3 frames
logExpect(getOutputLimited(0, 25), bringToCircleBorder([0, 25])
, "down dash pivot. upY extend-nerf timing edge case")
currentTimeMS += 1 + 0.000001
logExpect(getOutputLimited(0, 25), [0, 25]
, "down dash pivot. upY extend-nerf timelimit expiration")



logAppend("pivotLockouts finish`n")