#Requires AutoHotkey v1.1
/*  constants... extracted from the game engine, and other sources of information.
    the idea and comments behind these constants is copied from CarVac/HayBox.
    I sourced most from CarVac/HayBox, Altimor's Stickmap and the Melee Analog Reference Project discord
*/

ANALOG_STEP := 1
MS_PER_FRAME := 1000 / 60  ; game runs at 60 fps
PI := 3.141592653589793
DEG_TO_RADIAN := PI / 180
UNITCIRC_TO_INT := 80 ; factor for converting coordinate formats
INT_TO_UNITCIRC := 1/80
ANALOG_STICK_OFFSETCANCEL := -128 ; for converting unsigned bytes into 0-centered coordinatees

ANALOG_STICK_MIN := -80 ; <= neg coordinate, then it's inside down/left unit circle range
ANALOG_DEAD_MIN := -22 ; <= neg coordinate, then it's inside the deadzone
ANALOG_DEAD_MAX := 22 ; >= coordinate, then it's inside the deadzone
ANALOG_STICK_MAX := 80 ; >= coordinate, then it's inside up/right unit circle range
ANALOG_CROUCH := -50 ; >= neg y coordinate, then the character is holding crouch
ANALOG_DOWNSMASH := -53 ; >= neg y coordinate, then the character could either 
                        ; downsmash, shield drop, fastfall, drop from platform etc
ANALOG_TAPJUMP := 55 ; <= y coordinate, then the character is in u-smash or tap-jump range
ANALOG_DASH_LEFT := -64 ; >= neg x coordinate, then f-smash left or dash left
ANALOG_DASH_RIGHT := 64 ; <= x coordinate, means f-smash right or dash right
; the following four constants apply only when the other coordinate component is in the deadzone
ANALOG_SDI_LEFT := -56 ; >= neg x coordinate, then it's left sdi range
ANALOG_SDI_RIGHT := 56 ; <= x coordinate, then it's right sdi range
ANALOG_SDI_UP := 56 ; <= y coordinate, then it's up sdi range
ANALOG_SDI_DOWN := -56 ; >= neg y coordinate, then it's down sdi range

MELEE_SDI_RAD := 56 * 56 ; <= x^2+y^2, and not in x or y deadzone then it's diagonal SDI range
ANALOG_ANGLE_FIFTY_RATIO_13 := tan(50 * DEG_TO_RADIAN)  ; <= y/x where y and x are the same sign and out of
                                                        ; deadzone, then coordinate angle is 50 degrees+
                                                        ; away from x axis
ANALOG_ANGLE_FIFTY_RATIO_24 := -tan(50 * DEG_TO_RADIAN) ; >= y/x where y and x are a different sign
                                                        ; (quadrants 2 and 4), then, same as above
ANALOG_ANGLE_XAXIS_RATIO_13 := tan(20 * DEG_TO_RADIAN)  ; > y/x where y and x are the same sign and out of
                                                        ; deadzone, then angle is too close to X axis
ANALOG_ANGLE_XAXIS_RATIO_24 := -tan(20 * DEG_TO_RADIAN) ; < y/x where y and x are a different sign
                                                        ; (quadrants 2 and 4), then, same as above
ANALOG_ANGLE_YAXIS_RATIO_13 := tan((90 - 20) * DEG_TO_RADIAN)   ; < y/x where y and x are the same sign
                                                                ; and out of deadzone,
                                                                ; then angle is too close to Y axis
ANALOG_ANGLE_YAXIS_RATIO_24 := -tan((90 - 20) * DEG_TO_RADIAN)  ; > y/x where y and x are a different sign
                                                                ; (quadrants 2 and 4), then, same as above
ANALOG_SPECIAL_LEFT := -48 ; >= neg x coordinate, then it's in range to forward-B to the left
ANALOG_SPECIAL_RIGHT := 48 ; <= x coordinate, then it's in range to forward-B to the right
ANALOG_SPECIAL_DOWN := -44 ; >= neg y coordinate, then it's down-B range
ANALOG_SPECIAL_UP := 44 ; <= y coordinate, then it's up-B range
ANALOG_SPOTDODGE_MIN_LEFT := -55    ; <= neg x coordinate, or
ANALOG_SPOTDODGE_MIN_RIGHT := 55    ; >= x coordinate, then you are in spotdodge or middle shield-drop
                                    ; horizontal range 
ANALOG_SPOTDODGE_MIN_VERTICAL := -56    ; >= y coordinate, then you are in spotdodge vertical
                                        ; (and below middle shield-drop) range

; nerf constants
TIMELIMIT_DOWNUP := 3 * MS_PER_FRAME    ; // ms, how long after a crouch to upward input should it begin a jump?
                                        ; also uncrouch timing lockout expiration time
JUMP_TIME := 2 * MS_PER_FRAME ; // after a recent crouch to upward input, always hold full up only for 2 frames
                              ; currently unused
TIMELIMIT_FRAME := MS_PER_FRAME   ; for use in pivot feasibility check
TIMELIMIT_HALFFRAME := MS_PER_FRAME / 2 ; ditto
TIMELIMIT_DEBOUNCE := 6 ; ms, to combat the effect of mechanical switch bounce. 
                        ; i don't know if this is relevant to modern keyboards
TIMELIMIT_SIMULTANEOUS := 4     ; ms > current time minus last input timestamp*, means that this input
                                ; and last one can be considered as 
                                ; an intended single input and not two separate inputs
                                ; *: timekeeping begins when pressing 1 button and ends
                                ;    if and only if 4ms pass
TIMELIMIT_TAPSHUTOFF := 4 * MS_PER_FRAME    ; 4 frames for tap jump shutoff, also d-smash shutoff and
                                            ; related actions

TIMELIMIT_BURSTSDI := 5.5 * MS_PER_FRAME ; ms
TIMELIMIT_TAP_PLUS := 8.5 * MS_PER_FRAME ; // 3 additional frames

TIMELIMIT_CARDIAG := 8 * MS_PER_FRAME ; ms, fyi cardiag means cardinal diagonal

TIMELIMIT_PIVOTTILT := 8 * MS_PER_FRAME ; pivot timing lockout expiration time
TIMELIMIT_PIVOTTILT_YDASH := 5 * MS_PER_FRAME
TIMESTALE_PIVOT_INPUTSEQUENCE := 15 * MS_PER_FRAME  ; when is a dash entry for a pivot considered stale?
                                                    ; also: falcon dash's initial animation length
                                                    ; only surpassed by mew-two
FORCE_FTILT := 30 ; value taken from CarVac haybox; [30, 30] + A button executes an angled ftilt
TIMESTALE_SDI_INPUTSEQUENCE := 8 * MS_PER_FRAME

FUZZ_1_00_PROBABILITY := 50 ; %, probability that the X output is 0.9875 instead of 1.0000
