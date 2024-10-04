; the idea and comments behind these constants is copied from CarVac/HayBox
ANALOG_STEP := 1
MS_PER_FRAME := 1000 / 60  ; game runs at 60 fps
PI := 3.141592653589793
DEG_TO_RADIAN := PI / 180

ANALOG_STICK_MIN := -80 ; > coordinate, then it's out of stick range
ANALOG_DEAD_MIN := -22 ; > coordinate, then it's outside the deadzone and to the left/down
ANALOG_STICK_NEUTRAL := 0
ANALOG_DEAD_MAX := 22 ; < coordinate, then it's outside the deadzone and to the right/up
ANALOG_STICK_MAX := 80 ; < coordinate, then it's out of stick range
ANALOG_CROUCH := -50 ; >= y coordinate, then the character is holding crouch
ANALOG_DOWNSMASH := -53 ; >= y coordinate, then the character could downsmash, shield drop, fastfall, drop from platform etc
ANALOG_TAPJUMP := 55 ; <= y coordinate, then the character is in u-smash or tap-jump range
ANALOG_DASH_LEFT := -64 ; >= x coordinate, then f-smash or dash left
ANALOG_DASH_RIGHT := 64 ; <= x coordinate, means f-smash or dash right
ANALOG_SDI_LEFT := -56 ; >= x coordinate, then it's left sdi range
ANALOG_SDI_RIGHT := 56 ; <= x coordinate, then it's right sdi range
ANALOG_SDI_UP := 56 ; <= y coordinate
ANALOG_SDI_DOWN := - 56 ; >= y coordinate
MELEE_SDI_RAD := 56 * 56 ; <= x^2+y^2, and not in x or y deadzone then it's diagonal SDI range
ANALOG_ANGLE_FIFTY_RATIO_13 := tan(50 * DEG_TO_RADIAN) ; <= y/x where y and x are the same sign and out of deadzone,
                                                  ; then coordinate angle is 50 degrees or above away from x axis
ANALOG_ANGLE_FIFTY_RATIO_24 := -tan(50 * DEG_TO_RADIAN) ; >= y/x where y and x are a different sign (quadrants 2 and 4)
ANALOG_ANGLE_XAXIS_RATIO_13 := tan(20 * DEG_TO_RADIAN) ; > y/x where y and x are the same sign and out of deadzone,
                                                          ; then angle is too close to X axis
ANALOG_ANGLE_XAXIS_RATIO_24 := -tan(20 * DEG_TO_RADIAN)
ANALOG_ANGLE_YAXIS_RATIO_13 := tan((90 - 20) * DEG_TO_RADIAN) ; < y/x where y and x are the same sign and out of deadzone,
                                                          ; then angle is too close to Y axis
ANALOG_ANGLE_YAXIS_RATIO_24 := -tan((90 - 20) * DEG_TO_RADIAN)                                                          
ANALOG_SPECIAL_LEFT := -48 ; >= x coordinate, then it's in range to forward-B to the left
ANALOG_SPECIAL_RIGHT := 48 ; <= x coordinate, then it's in range to forward-B to the right
ANALOG_SPECIAL_DOWN := -44 ; >= y coordinate, then it's down-B range
ANALOG_SPECIAL_UP := 44 ; <= y coordinate, then it's up-B range
ANALOG_SPOTDODGE_MIN_LEFT := -55 ; <= x coordinate, and-
ANALOG_SPOTDODGE_MIN_RIGHT := 55 ; >= x coordinate, then you are in spotdodge or middle shield-drop horizontal range 
ANALOG_SPOTDODGE_MIN_VERTICAL := -56 ; >= y coordinate, then you are in spotdodge vertical (and below middle shield-drop) range

; nerf constants

TIMELIMIT_DOWNUP := 3 * MS_PER_FRAME ; // ms, how long after a crouch to upward input should it begin a jump?
JUMP_TIME := 2 * MS_PER_FRAME ; // after a recent crouch to upward input, always hold full up only for 2 frames

TIMELIMIT_FRAME := MS_PER_FRAME   ; for use in pivot feasibility check
TIMELIMIT_HALFFRAME := MS_PER_FRAME / 2
TIMELIMIT_DEBOUNCE := 6 ; ms, to combat the effect of mechanical switch bounce. i don't know if this is relevant in today's keyboards
TIMELIMIT_SIMULTANEOUS := 3.1 ; ms > current time minus last input timestamp, means that this input and last one can be considered as 
                              ; an intended single input and not two separate inputs
TIMELIMIT_TAPSHUTOFF := 4 * MS_PER_FRAME ; 4 frames for tap jump shutoff, also d-smash shutoff and similar actions

TIMELIMIT_BURSTSDI := 5.5 * MS_PER_FRAME ; ms
TIMELIMIT_TAP_PLUS := 8.5 * MS_PER_FRAME ; // 3 additional frames

TIMELIMIT_CARDIAG := 8 * MS_PER_FRAME ; ms, fyi cardiag means cardinal diagonal

TIMELIMIT_PIVOTTILT := 8 * MS_PER_FRAME
TIMELIMIT_PIVOTTILT_YDASH := 5 * MS_PER_FRAME
TIMESTALE_PIVOT_INPUTSEQUENCE := 15 * MS_PER_FRAME
FORCE_FTILT := 30 ; value taken from CarVac haybox
TIMESTALE_SDI_INPUTSEQUENCE := 8 * MS_PER_FRAME

FUZZ_1_00_PROBABILITY := 50 ; percent of probability that the X output is 0.9875 instead of 1.0000
